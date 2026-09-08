if status is-interactive
    # Vi mode must be enabled BEFORE atuin init, otherwise switching key
    # bindings wipes the binds atuin made.
    set -g fish_key_bindings fish_vi_key_bindings

    # Starship custom prompt
    starship init fish | source

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source
    command -v rbenv &> /dev/null && rbenv init - fish | source

    # Atuin: define helper functions but don't let it bind keys itself.
    # Keybindings (including hjkl in vi normal mode) live in
    # fish_user_key_bindings.fish so they apply to both vi modes.
    set -gx ATUIN_NOBIND "true"
    command -v atuin &> /dev/null && atuin init fish | source
end
# cat ~/.local/state/caelestia/sequences.txt 2> /dev/null

# pnpm
set -gx PNPM_HOME "/home/colour/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# opencode
fish_add_path /home/colour/.opencode/bin
