function fish_user_key_bindings
    for mode in insert default
        # Alt+Backspace / Escape+Backspace
        bind -M $mode \e\x7f backward-kill-word
        bind -M $mode \e\b backward-kill-word

        # Atuin history search
        bind -M $mode \cr _atuin_search
        bind -M $mode \e\[A _atuin_bind_up
        bind -M $mode \eOA _atuin_bind_up
    end

    # Neovim-style history in vi normal mode:
    #   j/k open the Atuin search TUI (navigated with hjkl inside),
    #   h/l keep their fish vi bindings (backward-char / forward-char).
    bind -M default k _atuin_search
    bind -M default j _atuin_search
end
