//
//  main.swift
//  RunningCatMenuBar
//
//  Created by Ruslan Deianov on 19.07.2025.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the main window and dock icon
        NSApp.setActivationPolicy(.accessory)

        // Create and setup the status bar controller
        statusBarController = StatusBarController()
    }

    func applicationWillTerminate(_ notification: Notification) {
        statusBarController?.cleanup()
    }

    @objc private func quitApplication() {
        statusBarController?.quitApplication()
    }
}

// Main entry point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
