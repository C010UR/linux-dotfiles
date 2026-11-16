#!/usr/bin/env bash
#
# bootstrap.sh — turn a fresh Arch-based install into this system.
#
# Run as your normal user (it sudo's for system bits). Idempotent.
#   ./bootstrap.sh            # prompt before touching /etc
#   ./bootstrap.sh --yes      # no prompt
#   ./bootstrap.sh --dry-run  # show what would happen
#
set -Eeuo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSUME_YES=0
DRY_RUN=0
for a in "$@"; do
  case "$a" in
    -y|--yes) ASSUME_YES=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown arg: $a" >&2; exit 2 ;;
  esac
done

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }
run()  { if (( DRY_RUN )); then printf '   [dry] %s\n' "$*"; else "$@"; fi; }
# like run(), but drains stdin so an upstream `pkgs` pipe never gets SIGPIPE
run_stdin() { if (( DRY_RUN )); then cat >/dev/null; printf '   [dry] %s\n' "$*"; else "$@"; fi; }
sudorun() { if (( DRY_RUN )); then printf '   [dry] sudo %s\n' "$*"; else sudo "$@"; fi; }
pkgs() { grep -vE '^[[:space:]]*(#|$)' "$1"; }

command -v pacman >/dev/null || { echo "not an Arch-based system" >&2; exit 1; }
(( EUID == 0 )) && { echo "run as your user, not root" >&2; exit 1; }

# Refuse to run in the live ISO: it would write to the ephemeral overlay and
# touch the live /etc instead of the installed system.
if [[ -d /run/archiso || -e /etc/archiso ]]; then
  cat >&2 <<'EOF'
error: this looks like the live ISO (liveuser / archiso).

Install CachyOS first, reboot into the installed disk, then run bootstrap.sh
there. Nothing done here would survive a reboot.
EOF
  exit 1
fi

# ---------------------------------------------------------------- keyrings
# A fresh ISO's keyring can be older than the repos, which shows up as
# "signature ... is unknown trust" / "corrupted (PGP signature)" for
# unrelated packages. Refresh before upgrading anything.
say "Refreshing pacman keyrings"
sudorun pacman-key --init || warn "pacman-key --init failed"
sudorun pacman-key --populate archlinux || warn "could not populate archlinux keys"
sudorun pacman-key --populate cachyos || warn "could not populate cachyos keys"
keyrings=(archlinux-keyring)
pacman -Q cachyos-keyring >/dev/null 2>&1 && keyrings+=(cachyos-keyring)
sudorun pacman -Sy --needed --noconfirm "${keyrings[@]}" \
  || warn "keyring packages failed to update — if this persists, run 'sudo pacman-key --refresh-keys'"
sudorun pacman -Su --needed --noconfirm

# ---------------------------------------------------------------- packages
say "Installing native packages (pacman)"
sudorun pacman -S --needed --noconfirm chezmoi
pkgs "$REPO/packages/native.txt" | run_stdin sudo pacman -S --needed --noconfirm -

if [[ -s "$REPO/packages/aur.txt" ]]; then
  if command -v paru >/dev/null; then AUR=paru
  elif command -v yay >/dev/null; then AUR=yay
  else
    warn "no AUR helper (paru/yay) found — skipping AUR packages"
    warn "install one, then: <helper> -S --needed - < packages/aur.txt"
    AUR=""
  fi
  if [[ -n "$AUR" ]]; then
    say "Installing AUR packages ($AUR)"
    pkgs "$REPO/packages/aur.txt" | run_stdin "$AUR" -S --needed --noconfirm -
  fi
fi

if [[ -s "$REPO/packages/flatpak.txt" ]]; then
  say "Installing flatpaks"
  run flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
  while read -r app; do
    run flatpak install -y --noninteractive flathub "$app" || warn "flatpak failed: $app"
  done < <(pkgs "$REPO/packages/flatpak.txt")
fi

# ------------------------------------------------------------ system files
say "System config (/etc, /usr/local/sbin) from system/"
if (( ! DRY_RUN && ! ASSUME_YES )); then
  echo "About to copy the tree in $REPO/system/ over / ."
  read -rp "Continue? [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]] || { echo "aborted at system files"; exit 1; }
fi
sudorun cp -a "$REPO/system/." /
sudorun systemctl daemon-reload

say "Enabling system units"
while read -r u; do
  [[ "$u" == *@* ]] && continue          # skip template units
  sudorun systemctl enable "$u" 2>/dev/null || warn "could not enable $u"
done < <(pkgs "$REPO/units/system.txt")

say "Enabling user units"
while read -r u; do
  run systemctl --user enable "$u" 2>/dev/null || warn "could not enable user unit $u"
done < <(pkgs "$REPO/units/user.txt")

# initramfs + bootloader only matter if those files changed
if (( ! DRY_RUN )); then
  say "Rebuilding initramfs (mkinitcpio -P)"
  sudorun mkinitcpio -P || warn "mkinitcpio failed — check system/etc/mkinitcpio.conf"
fi

# ------------------------------------------------------------------ dotfiles
say "Applying dotfiles (chezmoi)"
run chezmoi --source "$REPO" apply --verbose

say "Done."
cat <<'EOF'

Next steps for a manual pass (cannot be automated safely):
  * git identity / GPG key: check ~/.gitconfig and `gpg --list-secret-keys`
  * disk layout + fstab: see README (btrfs subvolumes, UUIDs are per-machine)
  * WiFi/VPN credentials: NetworkManager, Mullvad, Tailscale/Twingate, Zerotier
  * browser/app profiles and logins are intentionally not managed
  * enable anything machine-specific you skipped above
EOF
