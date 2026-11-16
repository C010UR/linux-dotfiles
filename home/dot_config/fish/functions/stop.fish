function stop --description 'Stop a managed service'
    if test (count $argv) -ne 1
        echo "Usage: stop <service>" >&2
        return 1
    end

    switch $argv[1]
        case zerotier
            sudo systemctl stop zerotier-one
        case twingate
            sudo twingate service-stop
        case '*'
            echo "Unknown service: $argv[1]" >&2
            return 1
    end
end
