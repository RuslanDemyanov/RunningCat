//
//  CPUDetailView.swift
//  RunningCatMenuBar
//
//  Created by Ruslan Deianov on 19.07.2025.
//

import Combine
import SwiftUI

struct CPUDetailView: View {
    @StateObject private var cpuMonitor = CPUMonitor()
    @State private var animationSpeed: CGFloat = 1.0
    let onQuit: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "cat")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("CPU Monitor")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Quit") {
                    onQuit()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .keyboardShortcut("q", modifiers: .command)
            }


            // CPU Usage Display
            VStack(spacing: 12) {
                // Main CPU percentage
                HStack {
                    Text("CPU Usage:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(cpuMonitor.getCPUUsageString())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(cpuUsageColor)
                }

                // CPU Usage Bar
                ProgressView(value: cpuMonitor.cpuUsage, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: cpuUsageColor))
                    .scaleEffect(y: 2.0)

                // Animation Speed
                HStack {
                    Text("Cat Speed:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(String(format: "%.1fx", animationSpeed))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                // Cat State Description
                HStack {
                    Text("Status:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(LottieStatusBarView.getCatStateDescription(cpuMonitor.cpuUsage))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .frame(width: 300, height: 260)
        .onReceive(cpuMonitor.$cpuUsage) { cpuUsage in
            // Update animation speed based on CPU usage
            animationSpeed = LottieStatusBarView.mapCPUToAnimationSpeed(cpuUsage)
        }
    }

    private var cpuUsageColor: Color {
        switch cpuMonitor.cpuUsage {
        case 0.0..<0.3:
            return .green
        case 0.3..<0.7:
            return .yellow
        default:
            return .red
        }
    }
}

// Extension for notification names
extension Notification.Name {
    static let closePopover = Notification.Name("closePopover")
}

struct CPUDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CPUDetailView(onQuit: {})
    }
}
