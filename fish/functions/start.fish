function start --description 'Start a managed service'
    if test (count $argv) -ne 1
        echo "Usage: start <service>" >&2
        return 1
    end

    switch $argv[1]
        case zerotier
            sudo systemctl start zerotier-one
        case twingate
            twingate start
        case '*'
            echo "Unknown service: $argv[1]" >&2
            return 1
    end
end
