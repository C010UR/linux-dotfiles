function tmuxfresh --description 'Reset current tmux session to one fresh window'
    if not set -q TMUX
        echo "tmuxfresh: run this inside a tmux session"
        return 1
    end

    set -l session (tmux display-message -p '#S')
    set -l fresh_name fresh

    if tmux list-windows -t "$session" -F '#W' | string match -q -- "$fresh_name"
        set fresh_name "fresh-(date +%s)"
    end

    tmux new-window -t "$session" -n "$fresh_name" -c "$HOME"
    tmux kill-window -t "$session" -a
    tmux move-window -s "$session:$fresh_name" -t "$session:1"
    tmux select-window -t "$session:1"
end
