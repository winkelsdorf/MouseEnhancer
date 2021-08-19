#!/bin/bash

sudo launchctl unload ~/Library/LaunchAgents/de.winkelsdorf.MouseEnhancer.plist
sudo rm ~/Library/LaunchAgents/de.winkelsdorf.MouseEnhancer.plist
sudo rm /usr/local/bin/mouseenhancer
