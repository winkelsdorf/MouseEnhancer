//
//  main.swift
//  MouseEnhancer
//
//  Created by Frederik Winkelsdorf on 19.08.21.
//

import Foundation
import Cocoa

enum MediaKeys: UInt32 {
    case volumeUp = 0
    case volumeDown = 1
}

// see https://stackoverflow.com/questions/11045814/emulate-media-key-press-on-mac
func mediaKeyPress(key: UInt32, down: Bool) {
    let downValue: UInt = down ? 0xa00 : 0xb00
    let flags = NSEvent.ModifierFlags(rawValue: downValue)
    let data1 = Int((key << 16) | UInt32(downValue))
    let event = NSEvent.otherEvent(
        with: .systemDefined,
        location: .zero,
        modifierFlags: flags,
        timestamp: .zero,
        windowNumber: .zero,
        context: nil,
        subtype: 8,
        data1: data1,
        data2: -1
    )
    
    let cgEvent = event?.cgEvent
    cgEvent?.post(tap: .cghidEventTap)
}

var eventTapCallback: CGEventTapCallBack = { _, type, event, _ in
    if [.otherMouseDown].contains(type) {
        let mouseButtonNumber = event.getIntegerValueField(.mouseEventButtonNumber)
        
        switch mouseButtonNumber {
            case 4: // Upper Side Button
                mediaKeyPress(key: MediaKeys.volumeUp.rawValue, down: true)
                mediaKeyPress(key: MediaKeys.volumeUp.rawValue, down: false)
                return nil
            case 3: // Lower Side Button
                mediaKeyPress(key: MediaKeys.volumeDown.rawValue, down: true)
                mediaKeyPress(key: MediaKeys.volumeDown.rawValue, down: false)
                return nil
            default:
                break
        }
    }
    
    return Unmanaged.passRetained(event)
}

guard let eventTap = CGEvent.tapCreate(
    tap: .cghidEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: CGEventMask(1 << CGEventType.otherMouseDown.rawValue),
    callback: eventTapCallback,
    userInfo: nil
) else {
    print("Failed to create event tap.")
    print("Check Accessibility Permissions for Binary in System Preferences.")
    exit(1)
}

let runloopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runloopSource, CFRunLoopMode.commonModes)
CGEvent.tapEnable(tap: eventTap, enable: true)

CFRunLoopRun()
