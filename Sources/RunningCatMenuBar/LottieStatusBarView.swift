//
//  LottieStatusBarView.swift
//  RunningCatMenuBar
//
//  Created by Ruslan Deianov on 19.07.2025.
//

import Cocoa
import Foundation
import Lottie

class LottieStatusBarView: NSView {
    
    private var animationView: LottieAnimationView?
    private var currentAnimationSpeed: CGFloat = 1.0

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupAnimation()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAnimation()
    }

    private func setupAnimation() {
        // Load the Lottie animation from package resources
        guard
            let animationURL = Bundle.module.url(forResource: "cat walking", withExtension: "json"),
            let animation = LottieAnimation.filepath(animationURL.path)
        else {
            print("❌ Could not load 'cat walking' animation from package resources")
            setupFallbackView()
            return
        }

        // Create and configure the animation view
        animationView = LottieAnimationView(animation: animation)
        guard let animationView = animationView else { return }

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        animationView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(animationView)

        // Set up constraints
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: topAnchor),
            animationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // Start the animation
        animationView.play()

        print("✅ Lottie animation loaded and playing")
    }

    private func setupFallbackView() {
        // Create a simple fallback view with a cat emoji or icon
        let textField = NSTextField(labelWithString: "🐱")
        textField.font = NSFont.systemFont(ofSize: 16)
        textField.textColor = NSColor.controlTextColor
        textField.translatesAutoresizingMaskIntoConstraints = false

        addSubview(textField)

        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        print("⚠️ Using fallback cat emoji")
    }

    func updateAnimationSpeed(_ speed: CGFloat) {
        guard let animationView = animationView else { return }

        // Smooth the speed changes to avoid jarring transitions
        let smoothedSpeed = smoothSpeedTransition(from: currentAnimationSpeed, to: speed)
        currentAnimationSpeed = smoothedSpeed

        animationView.animationSpeed = smoothedSpeed

        // If the animation stopped due to very low speed, restart it
        if smoothedSpeed > 0.05 && !animationView.isAnimationPlaying {
            animationView.play()
        }
    }

    private func smoothSpeedTransition(from currentSpeed: CGFloat, to targetSpeed: CGFloat)
        -> CGFloat
    {
        let maxChange: CGFloat = 0.3  // Maximum speed change per update
        let difference = targetSpeed - currentSpeed

        if abs(difference) <= maxChange {
            return targetSpeed
        } else {
            return currentSpeed + (difference > 0 ? maxChange : -maxChange)
        }
    }

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()

        // Set wantsLayer when view is added to hierarchy
        wantsLayer = true

        // Ensure the animation is properly sized when added to the status bar
        if superview != nil {
            needsLayout = true
        }
    }

    override var intrinsicContentSize: NSSize {
        return NSSize(width: 22, height: 22)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        wantsLayer = true
    }

    override func updateLayer() {
        super.updateLayer()

        // Ensure the view adapts to dark/light mode
        if let layer = layer {
            layer.backgroundColor = NSColor.clear.cgColor
        }
    }

    // Method to pause animation (useful for power saving)
    func pauseAnimation() {
        animationView?.pause()
    }

    // Method to resume animation
    func resumeAnimation() {
        animationView?.play()
    }

    // Method to check if animation is playing
    var isAnimationPlaying: Bool {
        return animationView?.isAnimationPlaying ?? false
    }

    deinit {
        animationView?.stop()
        print("🧹 LottieStatusBarView deallocated")
    }
}

// MARK: - Animation Speed Mapping Extensions
extension LottieStatusBarView {

    /// Maps CPU usage percentage to cat behavior
    /// - Parameter cpuUsage: CPU usage from 0.0 to 1.0
    /// - Returns: Animation speed representing cat's running speed
    static func mapCPUToAnimationSpeed(_ cpuUsage: Double) -> CGFloat {
        switch cpuUsage {
        case 0.0..<0.05:
            // Almost idle - cat sleeps (very slow)
            return 0.1
        case 0.05..<0.15:
            // Low usage - cat walks slowly
            return 0.3 + CGFloat(cpuUsage - 0.05) * 3.0
        case 0.15..<0.30:
            // Moderate usage - normal walking
            return 0.6 + CGFloat(cpuUsage - 0.15) * 2.0
        case 0.30..<0.60:
            // High usage - jogging
            return 0.9 + CGFloat(cpuUsage - 0.30) * 2.5
        case 0.60..<0.85:
            // Very high usage - running
            return 1.65 + CGFloat(cpuUsage - 0.60) * 4.0
        default:
            // Extreme usage - sprinting!
            return 2.65 + CGFloat(cpuUsage - 0.85) * 8.0
        }
    }

    /// Get a descriptive string for the current CPU state
    /// - Parameter cpuUsage: CPU usage from 0.0 to 1.0
    /// - Returns: Human-readable description of cat's state
    static func getCatStateDescription(_ cpuUsage: Double) -> String {
        switch cpuUsage {
        case 0.0..<0.05:
            return "😴 Cat is sleeping"
        case 0.05..<0.15:
            return "🚶‍♂️ Cat is walking slowly"
        case 0.15..<0.30:
            return "🚶 Cat is walking"
        case 0.30..<0.60:
            return "🏃‍♂️ Cat is jogging"
        case 0.60..<0.85:
            return "🏃 Cat is running"
        default:
            return "💨 Cat is sprinting!"
        }
    }
}
