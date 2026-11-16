function devtabs --description 'Append dev tabs into current tmux session'
    if not set -q TMUX
        echo "devtabs: run this inside a tmux session"
        return 1
    end

    set -l workspace "$HOME/.config/tmuxp/dev-tabs.yaml"

    if not test -f "$workspace"
        echo "devtabs: workspace file not found at $workspace"
        return 1
    end

    tmuxp load -a -y "$workspace"
end
