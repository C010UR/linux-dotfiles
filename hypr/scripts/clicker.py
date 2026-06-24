#!/usr/bin/env python3

import argparse
import json
import os
import signal
import shutil
import subprocess
import sys
import time

PID_FILE = "/tmp/hypr_autoclicker.pid"
STATE_FILE = "/tmp/hypr_autoclicker.state.json"
YDOTOOL_SOCKET = os.environ.get(
    "YDOTOOL_SOCKET",
    f"/run/user/{os.getuid()}/.ydotool_socket",
)

BUTTON_CODES = {
    "left": 272,
    "right": 273,
}

MODIFIER_CODES = {
    "ctrl": 29,
    "control": 29,
    "shift": 42,
    "alt": 56,
    "super": 125,
    "meta": 125,
    "win": 125,
}

KEY_CODES = {
    **{chr(c): 30 + (c - ord("a")) for c in range(ord("a"), ord("z") + 1)},
    "0": 11,
    "1": 2,
    "2": 3,
    "3": 4,
    "4": 5,
    "5": 6,
    "6": 7,
    "7": 8,
    "8": 9,
    "9": 10,
    "space": 57,
    "enter": 28,
    "return": 28,
    "tab": 15,
    "escape": 1,
    "esc": 1,
    "backspace": 14,
    "delete": 111,
    "insert": 110,
    "home": 102,
    "end": 107,
    "pageup": 104,
    "pagedown": 109,
    "up": 103,
    "down": 108,
    "left": 105,
    "right": 106,
    "minus": 12,
    "equal": 13,
    "plus": 13,
    "comma": 51,
    "period": 52,
    "dot": 52,
    "slash": 53,
    "semicolon": 39,
    "quote": 40,
    "backslash": 43,
    "backtick": 41,
    "grave": 41,
    "leftbracket": 26,
    "rightbracket": 27,
    **{f"f{i}": 58 + i for i in range(1, 13)},
}

stopping = False


def write_state(payload: dict):
    with open(STATE_FILE, "w") as f:
        json.dump(payload, f)


def remove_state_files():
    remove_pid_file()
    if os.path.exists(STATE_FILE):
        os.remove(STATE_FILE)


def ydotool_key(*tokens: str):
    subprocess.run(
        ["ydotool", "key", *tokens],
        check=True,
        stdin=subprocess.DEVNULL,
    )


def effective_hold_ms(hold_ms: int, interval: float) -> int:
    max_hold = max(1, int(interval * 1000 * 0.4))
    return max(1, min(hold_ms, max_hold))


def do_click(button: str, hold_ms: int):
    code = BUTTON_CODES[button]
    ydotool_key(f"{code}:1")
    time.sleep(hold_ms / 1000)
    ydotool_key(f"{code}:0")


def parse_key_combo(combo: str) -> list[int]:
    parts = [p.strip().lower() for p in combo.split("+") if p.strip()]
    if not parts:
        raise ValueError("Key combo cannot be empty")

    codes = []
    modifiers = []
    main_keys = []

    for part in parts:
        if part in MODIFIER_CODES:
            modifiers.append(MODIFIER_CODES[part])
        elif part in KEY_CODES:
            main_keys.append(KEY_CODES[part])
        else:
            raise ValueError(f"Unsupported key token: {part}")

    if not main_keys:
        raise ValueError("Key combo must include a non-modifier key")
    if len(main_keys) > 1:
        raise ValueError("Key combo must include exactly one non-modifier key")

    for mod in modifiers:
        codes.extend([mod, 1])
    codes.extend([main_keys[0], 1, main_keys[0], 0])
    for mod in reversed(modifiers):
        codes.extend([mod, 0])

    return codes


def do_keypress(combo: str):
    codes = parse_key_combo(combo)
    ydotool_key(*[f"{code}:{state}" for code, state in zip(codes[::2], codes[1::2])])


def remove_pid_file():
    if os.path.exists(PID_FILE):
        os.remove(PID_FILE)


def request_stop(sig, frame):
    global stopping
    stopping = True


def is_running():
    if not os.path.exists(PID_FILE):
        return None

    try:
        with open(PID_FILE, "r") as f:
            pid = int(f.read().strip())

        os.kill(pid, 0)
        return pid
    except Exception:
        remove_state_files()
        return None


def read_state():
    if not os.path.exists(STATE_FILE):
        return None
    try:
        with open(STATE_FILE, "r") as f:
            return json.load(f)
    except Exception:
        return None


def perform_action(action: str, button: str, keys: str | None, hold_ms: int):
    if action == "mouse":
        do_click(button, hold_ms)
    else:
        do_keypress(keys or "")


def action_loop(
    interval: float,
    action: str,
    button: str,
    keys: str | None,
    duration: float | None,
    hold_ms: int,
):
    global stopping

    with open(PID_FILE, "w") as f:
        f.write(str(os.getpid()))

    signal.signal(signal.SIGINT, request_stop)
    signal.signal(signal.SIGTERM, request_stop)

    deadline = time.monotonic() + duration if duration and duration > 0 else None
    hold_ms = effective_hold_ms(hold_ms, interval)
    next_tick = time.monotonic()

    try:
        while not stopping:
            if deadline is not None and time.monotonic() >= deadline:
                break

            perform_action(action, button, keys, hold_ms)

            next_tick += interval
            sleep_for = next_tick - time.monotonic()
            if sleep_for > 0:
                time.sleep(sleep_for)
            else:
                next_tick = time.monotonic()
    finally:
        remove_state_files()


def start_background(
    interval: float,
    action: str,
    button: str,
    keys: str | None,
    duration: float | None,
    hold_ms: int,
    state: dict,
):
    pid = os.fork()
    if pid > 0:
        print("Autoclicker started")
        return

    os.setsid()

    pid2 = os.fork()
    if pid2 > 0:
        os._exit(0)

    sys.stdout.flush()
    sys.stderr.flush()

    with open("/dev/null", "r") as devnull_in, open("/dev/null", "a+") as devnull_out:
        os.dup2(devnull_in.fileno(), 0)
        os.dup2(devnull_out.fileno(), 1)
        os.dup2(devnull_out.fileno(), 2)

    write_state(state)
    action_loop(interval, action, button, keys, duration, hold_ms)


def stop_running():
    pid = is_running()
    if not pid:
        print("Autoclicker is not running")
        return False

    try:
        os.killpg(os.getpgid(pid), signal.SIGTERM)
        print("Autoclicker stopped")
    except ProcessLookupError:
        remove_state_files()
        print("Stale PID file removed")
    except PermissionError:
        try:
            os.kill(pid, signal.SIGTERM)
            print("Autoclicker stopped")
        except ProcessLookupError:
            remove_state_files()
            print("Stale PID file removed")

    return True


def toggle(
    interval: float,
    action: str,
    button: str,
    keys: str | None,
    duration: float | None,
    hold_ms: int,
    state: dict,
):
    pid = is_running()
    if pid:
        stop_running()
    else:
        start_background(interval, action, button, keys, duration, hold_ms, state)


def print_status():
    pid = is_running()
    payload = {
        "running": pid is not None,
        "pid": pid,
        "state": read_state(),
    }
    print(json.dumps(payload))


def build_state(args, interval: float, hold_ms: int) -> dict:
    return {
        "interval": interval,
        "action": args.action,
        "button": args.button,
        "keys": args.keys,
        "duration": args.duration,
        "cps": args.cps,
        "cpm": args.cpm,
        "hold_ms": hold_ms,
    }


def ensure_backend_available():
    if shutil.which("ydotool") is None:
        raise SystemExit(
            "ydotool is not installed. Install ydotool and make sure ydotoold is running."
        )

    ready = subprocess.run(
        ["ydotool", "key", "0:0"],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    ).returncode == 0

    if ready:
        return

    raise SystemExit(
        f"ydotoold is not reachable at {YDOTOOL_SOCKET}. "
        "Run: systemctl --user enable --now ydotool.service"
    )


def main():
    parser = argparse.ArgumentParser(description="Hyprland autoclicker using ydotool")
    parser.add_argument("--toggle", action="store_true", help="Toggle autoclicker on/off")
    parser.add_argument("--stop", action="store_true", help="Stop autoclicker if running")
    parser.add_argument("--status", action="store_true", help="Print JSON status")

    rate_group = parser.add_mutually_exclusive_group(required=False)
    rate_group.add_argument("--cps", type=float, help="Actions per second")
    rate_group.add_argument("--cpm", type=float, help="Actions per minute")

    parser.add_argument(
        "--action",
        choices=["mouse", "key"],
        default="mouse",
        help="Repeated action type",
    )
    parser.add_argument(
        "--button",
        choices=["left", "right"],
        default="left",
        help="Mouse button to click",
    )
    parser.add_argument(
        "--keys",
        type=str,
        help="Key combo for key action, e.g. ctrl+c",
    )
    parser.add_argument(
        "--duration",
        type=float,
        help="Optional auto-stop duration in seconds",
    )
    parser.add_argument(
        "--hold-ms",
        type=int,
        default=10,
        help="Mouse button hold duration in milliseconds (default: 10)",
    )

    args = parser.parse_args()

    if args.status:
        print_status()
        return

    if args.stop:
        stop_running()
        return

    if args.action == "key" and not args.keys:
        raise ValueError("--keys is required when --action key")

    if args.action == "key":
        parse_key_combo(args.keys)

    if args.cps is not None:
        if args.cps <= 0:
            raise ValueError("CPS must be greater than 0")
        interval = 1.0 / args.cps
    elif args.cpm is not None:
        if args.cpm <= 0:
            raise ValueError("CPM must be greater than 0")
        interval = 60.0 / args.cpm
    elif args.toggle or args.stop:
        interval = 0.5
    else:
        raise ValueError("Either --cps or --cpm is required")

    if args.duration is not None and args.duration <= 0:
        raise ValueError("Duration must be greater than 0")

    if args.hold_ms <= 0:
        raise ValueError("--hold-ms must be greater than 0")

    ensure_backend_available()

    hold_ms = effective_hold_ms(args.hold_ms, interval)
    state = build_state(args, interval, hold_ms)

    if args.toggle:
        toggle(interval, args.action, args.button, args.keys, args.duration, hold_ms, state)
    else:
        write_state(state)
        action_loop(interval, args.action, args.button, args.keys, args.duration, hold_ms)


if __name__ == "__main__":
    main()
