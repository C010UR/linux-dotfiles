if status is-interactive
    # Better ls
    alias ls='eza --icons --color --group-directories-first -l'

    # Edge browser
    alias edge='flatpak run com.microsoft.Edge --ozone-platform=wayland --ozone-platform-hint=wayland --enable-features=TouchpadOverscrollHistoryNavigation --disable-features=WaylandWpColorManagerV1'

    alias a='~/.local/bin/tmux-start'

    # Abbrs
    abbr lg lazygit
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'

    abbr l ls
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'
end
