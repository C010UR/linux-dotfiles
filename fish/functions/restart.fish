function restart --description 'Restart a managed service'
    if test (count $argv) -ne 1
        echo "Usage: restart <service>" >&2
        return 1
    end

    switch $argv[1]
        case zerotier
            sudo systemctl restart zerotier-one
        case twingate
            twingate service stop
            and twingate start
        case '*'
            echo "Unknown service: $argv[1]" >&2
            return 1
    end
end
