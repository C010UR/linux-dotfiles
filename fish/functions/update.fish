function update
    set -l py_ver (pacman -Q python 2>/dev/null)
    set -l py_dir /usr/lib/python(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')

    yay -Syu --noconfirm --answerclean None --answerdiff None --answeredit None

    set -l to_rebuild

    for pkg in (pacman -Slq caelestia 2>/dev/null)
        test -n "$pkg"; and set -a to_rebuild $pkg
    end

    if test "$py_ver" != (pacman -Q python 2>/dev/null)
        echo "Python updated — queuing all Python package rebuilds…"
        for pkg in (yay -Qoq $py_dir 2>/dev/null)
            test -n "$pkg"; and set -a to_rebuild $pkg
        end
    end

    set to_rebuild (printf '%s\n' $to_rebuild | string match -rv '^\s*$' | sort -u)

    if test (count $to_rebuild) -gt 0
        yay -S $to_rebuild --noconfirm --answerclean All --answerdiff None --answeredit None
    end

    spicetify update
end
