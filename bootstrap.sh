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
showcmd() {
  local n=$#
  if (( n > 6 )); then
    printf '%s… (+%d more)' "$(printf '%s ' "${@:1:6}")" "$((n - 6))"
  else
    printf '%s' "$*"
  fi
}
run()  { if (( DRY_RUN )); then printf '   [dry] %s\n' "$(showcmd "$@")"; else "$@"; fi; }
sudorun() { if (( DRY_RUN )); then printf '   [dry] sudo %s\n' "$(showcmd "$@")"; else sudo "$@"; fi; }
pkgs() { grep -vE '^[[:space:]]*(#|$)' "$1"; }

# --------------------------------------------------------------- device DMI
dmi_string() {
  printf '%s %s %s' \
    "$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null)" \
    "$(cat /sys/class/dmi/id/product_name 2>/dev/null)" \
    "$(cat /sys/class/dmi/id/board_name 2>/dev/null)" | tr '[:upper:]' '[:lower:]'
}

# A profile matches when *every* glob line in its match file matches the
# lowercased DMI string. No match file, no match.
profile_matches() {
  local profile=$1 dmi pat seen=0
  dmi="$(dmi_string)"
  while IFS= read -r pat; do
    [[ -z "$pat" ]] && continue
    pat="${pat,,}"
    [[ "$dmi" == $pat ]] || return 1
    seen=1
  done < <(pkgs "$profile/match")
  (( seen ))
}

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
keyrings=(archlinux-keyring)
pacman -Si cachyos-keyring >/dev/null 2>&1 && keyrings+=(cachyos-keyring)
sudorun pacman -Sy --needed --noconfirm "${keyrings[@]}" \
  || warn "keyring packages failed to update — if this persists, run 'sudo pacman-key --refresh-keys'"
sudorun pacman-key --init || warn "pacman-key --init failed"
sudorun pacman-key --populate archlinux || warn "could not populate archlinux keys"
sudorun pacman-key --populate cachyos || warn "could not populate cachyos keys"
sudorun pacman -Su --needed --noconfirm

# ---------------------------------------------------------------- packages
mapfile -t NATIVE < <(pkgs "$REPO/packages/native.txt")
say "Installing native packages (pacman, ${#NATIVE[@]})"
sudorun pacman -S --needed --noconfirm chezmoi
sudorun pacman -S --needed --noconfirm "${NATIVE[@]}"

if [[ -s "$REPO/packages/aur.txt" ]]; then
  if command -v paru >/dev/null; then AUR=paru
  elif command -v yay >/dev/null; then AUR=yay
  else
    warn "no AUR helper (paru/yay) found — skipping AUR packages"
    warn "install one, then: grep -vE '^[[:space:]]*(#|\$)' packages/aur.txt | xargs <helper> -S --needed"
    AUR=""
  fi
  if [[ -n "$AUR" ]]; then
    mapfile -t AURLIST < <(pkgs "$REPO/packages/aur.txt")
    say "Installing AUR packages ($AUR, ${#AURLIST[@]})"
    run "$AUR" -S --needed --noconfirm "${AURLIST[@]}"
  fi
fi

if [[ -s "$REPO/packages/flatpak.txt" ]]; then
  say "Installing flatpaks"
  sudorun flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
  while read -r app; do
    sudorun flatpak install -y --noninteractive flathub "$app" || warn "flatpak failed: $app"
  done < <(pkgs "$REPO/packages/flatpak.txt")
fi

# ------------------------------------------------------------ device match
matched_profiles=()
for profile in "$REPO"/devices/*/; do
  [[ -f "$profile/match" ]] || continue
  profile="${profile%/}"
  profile_matches "$profile" && matched_profiles+=("$profile")
done
if (( ${#matched_profiles[@]} )); then
  say "Device profile: $(for p in "${matched_profiles[@]}"; do basename "$p"; done | paste -sd, -)"
else
  say "No device profile matches [$(dmi_string)] — hardware-specific parts skipped"
fi

# ------------------------------------------------------------ system files
say "System config (/etc) from system/"
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

# -------------------------------------------------------- device profiles
for profile in "${matched_profiles[@]}"; do
  name="$(basename "$profile")"
  say "Applying device profile: $name"

  if [[ -s "$profile/packages.txt" ]]; then
    mapfile -t PROFPKGS < <(pkgs "$profile/packages.txt")
    sudorun pacman -S --needed --noconfirm "${PROFPKGS[@]}"
  fi

  if [[ -s "$profile/local.txt" ]]; then
    ldir="$(cat "$profile/dir" 2>/dev/null || true)"
    ldir="${ldir/#\~/$HOME}"
    ldir="${LOCAL_DIR:-${ldir:-$HOME/Projects/$name}}"
    lrepo="$(cat "$profile/repo" 2>/dev/null || true)"
    lrepo="${LOCAL_REPO:-$lrepo}"

    if (( DRY_RUN )); then
      while read -r p; do
        [[ -z "$p" ]] && continue
        printf '   [dry] (cd %s/%s && makepkg -si --noconfirm --needed)\n' "$ldir" "$p"
      done < <(pkgs "$profile/local.txt")
    else
      say "  building local packages from $ldir"
      if [[ ! -d "$ldir" ]]; then
        if [[ -n "$lrepo" ]]; then
          run git clone "$lrepo" "$ldir"
        else
          warn "no repo configured for $name; cannot fetch $ldir"
        fi
      elif [[ ! -d "$ldir/.git" ]]; then
        warn "$ldir exists but is not a git checkout — using it as-is"
      fi
      while read -r p; do
        [[ -z "$p" ]] && continue
        if [[ -d "$ldir/$p" ]]; then
          ( cd "$ldir/$p" && makepkg -si --noconfirm --needed ) \
            || warn "build failed: $p (check makedepends)"
        else
          warn "local package dir missing: $ldir/$p"
        fi
      done < <(pkgs "$profile/local.txt")
    fi
  fi

  if [[ -d "$profile/system" ]]; then
    sudorun cp -a "$profile/system/." /
    sudorun systemctl daemon-reload
  fi

  if [[ -s "$profile/units.txt" ]]; then
    while read -r u; do
      [[ "$u" == *@* ]] && continue
      sudorun systemctl enable "$u" 2>/dev/null || warn "could not enable $u"
    done < <(pkgs "$profile/units.txt")
  fi
done

# initramfs + bootloader only matter if those files changed
if (( ! DRY_RUN )); then
  say "Rebuilding initramfs"
  # Use the real binary: CachyOS's /usr/local/bin/mkinitcpio wrapper prompts on a
  # tty to run limine-mkinitcpio, which hangs unattended. We run limine ourselves.
  if [[ -x /usr/bin/mkinitcpio ]]; then
    sudorun /usr/bin/mkinitcpio -P || warn "mkinitcpio failed — check system/etc/mkinitcpio.conf"
  else
    sudorun mkinitcpio -P || warn "mkinitcpio failed — check system/etc/mkinitcpio.conf"
  fi
  if command -v limine-update >/dev/null; then
    say "Regenerating limine entries"
    sudorun limine-update || warn "limine-update failed"
  fi
fi

# ------------------------------------------------------------------ dotfiles
say "Applying dotfiles (chezmoi)"
# Make plain `chezmoi` work afterwards, not just the --source invocation below.
if (( ! DRY_RUN )) && [[ ! -f "$HOME/.config/chezmoi/chezmoi.toml" ]]; then
  install -d "$HOME/.config/chezmoi"
  printf 'sourceDir = "%s"\n\n[git]\n    autoCommit = false\n' "$REPO" \
    > "$HOME/.config/chezmoi/chezmoi.toml"
fi
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
