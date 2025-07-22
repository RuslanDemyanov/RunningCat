//
//  StatusBarController.swift
//  RunningCatMenuBar
//
//  Created by Ruslan Deianov on 19.07.2025.
//

import Cocoa
import Combine
import Foundation
import SwiftUI

class StatusBarController: NSObject {
    
    private var statusBarItem: NSStatusItem?
    private var popover: NSPopover?
    private var cpuMonitor: CPUMonitor?
    private var animationView: LottieStatusBarView?
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        setupStatusBar()
        setupCPUMonitor()
    }

    private func setupStatusBar() {
        // Create status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusBarItem?.button else { return }

        // Create the Lottie animation view
        animationView = LottieStatusBarView(frame: NSRect(x: 0, y: 0, width: 22, height: 22))

        // Set the custom view as the button's view
        button.addSubview(animationView!)
        animationView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView!.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            animationView!.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            animationView!.widthAnchor.constraint(equalToConstant: 22),
            animationView!.heightAnchor.constraint(equalToConstant: 22),
        ])

        // Set up click action
        button.action = #selector(statusBarButtonClicked)
        button.target = self

        // Setup popover for detailed view
        setupPopover()
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 240)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: CPUDetailView(onQuit: quitApplication)
        )
    }

    private func setupCPUMonitor() {
        cpuMonitor = CPUMonitor()

        // Subscribe to CPU usage updates
        cpuMonitor?.$cpuUsage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cpuUsage in
                self?.updateAnimationSpeed(cpuUsage: cpuUsage)
            }
            .store(in: &cancellables)
    }

    private func updateAnimationSpeed(cpuUsage: Double) {
        // Map CPU usage (0-1) to animation speed (0.1-3.0)
        // Low CPU = slow cat, High CPU = fast cat
        let minSpeed: CGFloat = 0.1
        let maxSpeed: CGFloat = 3.0
        let animationSpeed = minSpeed + CGFloat(cpuUsage) * (maxSpeed - minSpeed)

        animationView?.updateAnimationSpeed(animationSpeed)

        // Update tooltip
        statusBarItem?.button?.toolTip = String(format: "CPU Usage: %.1f%%", cpuUsage * 100)
    }

    @objc private func statusBarButtonClicked() {
        // Check for modifier keys to show context menu
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp || (event?.modifierFlags.contains(.control) ?? false) {
            // Right-click or Ctrl+click - context menu will be shown automatically
            return
        }

        showPopover()
    }

    @objc private func showPopover() {
        guard let button = statusBarItem?.button else { return }

        if popover?.isShown == true {
            popover?.performClose(nil)
        } else {
            // Temporarily disable menu to show popover
            statusBarItem?.menu = nil
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    @objc func quitApplication() {
        cleanup()
        NSApplication.shared.terminate(nil)
    }

    func cleanup() {
        NotificationCenter.default.removeObserver(self)
        cancellables.removeAll()
        cpuMonitor?.stopMonitoring()
        cpuMonitor = nil
        statusBarItem = nil
        popover = nil
    }
}
