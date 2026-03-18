if status is-interactive
    # Starship custom prompt
    starship init fish | source

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source
    command -v rbenv &> /dev/null && rbenv init - fish | source
end
# cat ~/.local/state/caelestia/sequences.txt 2> /dev/null
