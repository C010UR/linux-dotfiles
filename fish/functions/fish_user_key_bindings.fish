function fish_user_key_bindings
    for mode in insert default
        # Alt+Backspace / Escape+Backspace
        bind -M $mode \e\x7f backward-kill-word
        bind -M $mode \e\b backward-kill-word
    end
end
