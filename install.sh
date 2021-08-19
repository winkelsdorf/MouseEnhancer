#!/bin/bash

swiftc -Osize MouseEnhancer/main.swift
sudo cp main /usr/local/bin/mouseenhancer
rm main

sudo cp de.winkelsdorf.MouseEnhancer.plist ~/Library/LaunchAgents
sudo launchctl load ~/Library/LaunchAgents/de.winkelsdorf.MouseEnhancer.plist

echo "🟠 Please add /usr/local/bin/mouseenhancer to Accessibility in System Preferences now"
