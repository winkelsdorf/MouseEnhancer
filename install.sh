#!/bin/zsh
set -eu

# Compile the Swift source into the default output file: ./main
rm -f ./main
swiftc -Osize MouseEnhancer/main.swift

# Install the executable
sudo install -d -o root -g wheel -m 755 /usr/local/bin
sudo install -o root -g wheel -m 755 \
    ./main \
    /usr/local/bin/mouseenhancer

# Install the per-user LaunchAgent
mkdir -p "$HOME/Library/LaunchAgents"
install -o "$USER" -g "$(id -gn)" -m 600 \
    ./de.winkelsdorf.MouseEnhancer.plist \
    "$HOME/Library/LaunchAgents/de.winkelsdorf.MouseEnhancer.plist"

# Remove quarantine metadata from the executable
sudo xattr -d \
    com.apple.quarantine \
    /usr/local/bin/mouseenhancer \
    2>/dev/null || true

# Remove quarantine metadata from the LaunchAgent
xattr -d \
    com.apple.quarantine \
    "$HOME/Library/LaunchAgents/de.winkelsdorf.MouseEnhancer.plist" \
    2>/dev/null || true

# Validate the property list
plutil -lint \
    "$HOME/Library/LaunchAgents/de.winkelsdorf.MouseEnhancer.plist"

# Remove the existing LaunchAgent
launchctl bootout \
    "gui/$(id -u)/de.winkelsdorf.MouseEnhancer" \
    2>/dev/null || true

# Load the LaunchAgent
launchctl bootstrap \
    "gui/$(id -u)" \
    "$HOME/Library/LaunchAgents/de.winkelsdorf.MouseEnhancer.plist"

# Start the LaunchAgent immediately
launchctl kickstart -k \
    "gui/$(id -u)/de.winkelsdorf.MouseEnhancer"

echo "🟠 Please allow /usr/local/bin/mouseenhancer in System Settings > Privacy & Security > Device Control and Data Access!"
