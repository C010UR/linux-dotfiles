#!/usr/bin/env python3
"""
Regenerate packages/native.txt, packages/aur.txt, packages/flatpak.txt,
packages/excluded.txt from the current machine.

Policy
------
Only *explicit* packages are considered (pacman -Qqe), because dependencies are
already pulled in by their parents.

An explicit package is kept when it ships a user-facing binary or .desktop entry,
or when it matches the system/hardware/runtime allowlist below (kernels,
firmware, drivers, GPU runtime, codecs, fonts, themes, metapackages). Everything
else is a library the apps pull in anyway, and goes to packages/excluded.txt
together with the manual DROP set.

Usage:  ./scripts/export-packages.py
"""
import fnmatch
import os
import re
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# No /usr/bin binary, but deliberately wanted.
KEEP = [
    "*firmware", "*-ucode", "linux-*", "base", "base-devel",
    "cachyos-*", "filesystem", "pacman", "systemd", "sudo",
    "*theme*", "*-fonts", "ttf-*", "noto-*", "*-fontconfig", "*-icons",
    "gst-*", "libdvdcss", "libopenraw", "poppler-glib", "vlc*", "ffmpeg*",
    "dolphin-plugins", "*-thumbnailers", "ffmpegthumbs",
    "proton-*", "steam", "wine*", "umu-launcher", "cachyos-gaming-meta",
    "hip-*", "rocm-*", "opencl-*", "lib32-*", "vulkan-radeon", "*-mesa",
    "xf86-*", "pipewire-alsa",
    "qemu-full", "docker-buildx", "teleport-connect", "nvm", "jdk*-openjdk",
    "bash-completion", "man-pages", "nano-syntax-highlighting",
    "appmenu-gtk-module", "nss-mdns", "bluez-hid2hci",
    "qt6-m3shapes-git", "python-hidapi",
]

# Libraries/leftovers never pinned explicitly. Values are notes for excluded.txt.
DROP = {
    "accountsservice": "pulled in by plasma-workspace",
    "alsa-plugins": "pulled in by cachyos-gaming-meta",
    "bluez": "pulled in by blueman",
    "bluez-libs": "pulled in by blueman / pipewire",
    "libdbusmenu-glib": "pulled in by libappindicator",
    "networkmanager-openvpn": "pulled in by proton-vpn",
    "python-defusedxml": "pulled in by freecad / glances",
    "python-packaging": "pulled in by many",
    "libgsf": "leftover, nothing requires it",
    "libwnck3": "leftover, nothing requires it",
    "volk": "build-time library",
    "vulkan-headers": "build-time library",
    "vulkan-utility-libraries": "build-time library",
    "vulkan-validation-layers": "development only",
}


def out(*cmd):
    return subprocess.run(cmd, capture_output=True, text=True).stdout


def ql(pkg):
    return out("pacman", "-Ql", pkg)


def has_bin(pkg):
    for line in ql(pkg).splitlines():
        if " " not in line:
            continue
        if re.search(r"(^|/)bin/[^/]+$", line.split(" ", 1)[1]):
            return True
    return False


def has_desktop(pkg):
    return "/usr/share/applications/" in ql(pkg)


def user_facing(pkg):
    return has_bin(pkg) or has_desktop(pkg)


def allowlisted(pkg):
    return any(fnmatch.fnmatch(pkg, pat) for pat in KEEP)


def main():
    native = sorted(out("pacman", "-Qqen").split())
    foreign = sorted(out("pacman", "-Qqem").split())
    flatpak = sorted(
        line for line in
        out("flatpak", "list", "--app", "--columns=application").splitlines()
        if line.strip()
    )
    if not native:
        sys.exit("refusing to write an empty package list (pacman failed?)")

    apps, system, excluded = [], [], []
    for p in native:
        if p in DROP:
            excluded.append((p, DROP[p]))
        elif user_facing(p):
            apps.append(p)
        elif allowlisted(p):
            system.append(p)
        else:
            excluded.append((p, "library, nothing requires it explicitly"))

    os.makedirs(f"{REPO}/packages", exist_ok=True)

    def write(name, header, lines):
        with open(f"{REPO}/packages/{name}", "w") as f:
            f.write(header)
            f.write("".join(line + "\n" for line in lines))

    write("native.txt",
          "# Native repo packages, explicit only. Regenerate with scripts/export-packages.py\n"
          "# Section: applications & tools\n",
          apps + ["", "# Section: system, drivers, firmware, kernels, metapackages"] + system)
    write("aur.txt", "# AUR / foreign explicit packages (install with paru/yay)\n", foreign)
    write("flatpak.txt", "# Flatpaks\n", flatpak)
    write("excluded.txt",
          "# Not installed explicitly. Libraries pulled in by parents, leftovers,\n"
          "# and build-time-only packages. Regenerate with scripts/export-packages.py\n",
          [f"{p:<28} # {why}" for p, why in sorted(excluded)])

    print(f"native: {len(apps) + len(system)}  aur: {len(foreign)}  "
          f"flatpak: {len(flatpak)}  excluded: {len(excluded)}")


if __name__ == "__main__":
    main()
