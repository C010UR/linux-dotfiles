#!/usr/bin/env python3
import evdev, subprocess, threading, time

HOLD_SEC = 3.0
timer = None

def find_power_device():
    for path in evdev.list_devices():
        try:
            d = evdev.InputDevice(path)
        except OSError:
            continue
        caps = d.capabilities(verbose=False)
        keys = caps.get(evdev.ecodes.EV_KEY, [])
        if evdev.ecodes.KEY_POWER in keys or evdev.ecodes.KEY_POWER2 in keys:
            return d
    return None

def trigger():
    subprocess.run(["/usr/local/sbin/graceful-shutdown-and-poweroff"])

def main():
    global timer
    while True:
        dev = find_power_device()
        if dev is None:
            time.sleep(5)
            continue
        for event in dev.read_loop():
            if event.type == evdev.ecodes.EV_KEY and event.code in (evdev.ecodes.KEY_POWER, evdev.ecodes.KEY_POWER2):
                if event.value == 1:
                    timer = threading.Timer(HOLD_SEC, trigger)
                    timer.daemon = True
                    timer.start()
                elif event.value == 0 and timer:
                    timer.cancel()
                    timer = None

if __name__ == "__main__":
    main()
