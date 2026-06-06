#!/bin/bash
# Recreate symlinks for quickshell config

ln -sfn /etc/xdg/quickshell/caelestia/components f1-window/components
ln -sfn /etc/xdg/quickshell/caelestia/modules f1-window/modules
ln -sfn /etc/xdg/quickshell/caelestia/services f1-window/services
ln -sfn /etc/xdg/quickshell/caelestia/utils f1-window/utils

echo "Symlinks created."
