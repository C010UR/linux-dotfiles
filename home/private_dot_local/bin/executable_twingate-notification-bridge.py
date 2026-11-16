#!/usr/bin/env python3
"""Forward unicast ActionInvoked signals to twingate-notifier's listener connection.

Noctalia >= 5.3 unicasts org.freedesktop.Notifications.ActionInvoked to the D-Bus
connection that called Notify(). twingate-notifier sends the notification on one
connection but listens for actions on another one, so it never sees the click.
This bridge eavesdrops on the session bus, and when an ActionInvoked signal is
addressed to a twingate-notifier connection, re-sends it (unicast) to the other
connections owned by that process.
"""

import json
import os
import subprocess
import sys

import dbus

MATCH = os.environ.get("TWINGATE_BRIDGE_MATCH", "twingate-notifier")
MATCH_TERMS = [term.strip() for term in MATCH.split(",") if term.strip()]


def process_matches(pid: int) -> bool:
    if pid <= 0:
        return False
    try:
        with open(f"/proc/{pid}/cmdline", "rb") as fh:
            cmdline = fh.read().replace(b"\0", b" ").decode("utf-8", "replace")
    except OSError:
        return False
    return any(term in cmdline for term in MATCH_TERMS)


def main() -> int:
    bus = dbus.SessionBus()
    our_name = bus.get_unique_name()
    dbus_obj = bus.get_object("org.freedesktop.DBus", "/org/freedesktop/DBus")
    dbus_iface = dbus.Interface(dbus_obj, "org.freedesktop.DBus")

    pid_cache: dict[str, int] = {}

    def connection_pid(name: str) -> int:
        if name in pid_cache:
            return pid_cache[name]
        try:
            pid = int(dbus_iface.GetConnectionUnixProcessID(name))
        except dbus.DBusException:
            pid = 0
        pid_cache[name] = pid
        return pid

    def connections_for_pid(pid: int) -> list[str]:
        try:
            names = dbus_iface.ListNames()
        except dbus.DBusException:
            return []
        return [
            name
            for name in names
            if name.startswith(":") and name != our_name and connection_pid(name) == pid
        ]

    monitor = subprocess.Popen(
        [
            "busctl",
            "--user",
            "monitor",
            "--json=short",
            "--match=type='signal',interface='org.freedesktop.Notifications',member='ActionInvoked'",
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=1,
    )
    assert monitor.stdout is not None

    for line in monitor.stdout:
        line = line.strip()
        if not line:
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("type") != "signal" or event.get("member") != "ActionInvoked":
            continue
        if event.get("sender") == our_name:
            continue  # our own forwarded copy
        destination = event.get("destination") or ""
        if not destination:
            continue  # already a broadcast signal
        data = (event.get("payload") or {}).get("data") or []
        if len(data) != 2:
            continue
        notification_id, action_key = data

        pid = connection_pid(destination)
        if not process_matches(pid):
            continue

        for target in connections_for_pid(pid):
            if target == destination:
                continue
            signal = dbus.lowlevel.SignalMessage(
                "/org/freedesktop/Notifications",
                "org.freedesktop.Notifications",
                "ActionInvoked",
            )
            signal.append(dbus.UInt32(int(notification_id)), dbus.String(str(action_key)))
            signal.set_destination(target)
            try:
                bus.send_message(signal)
                print(
                    f"forwarded ActionInvoked id={notification_id} key={action_key!r} to {target}",
                    file=sys.stderr,
                    flush=True,
                )
            except dbus.DBusException as exc:
                print(f"forward to {target} failed: {exc}", file=sys.stderr, flush=True)

    return monitor.wait()


if __name__ == "__main__":
    sys.exit(main())
