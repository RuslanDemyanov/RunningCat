//
//  CPUMonitor.swift
//  RunningCatMenuBar
//
//  Created by Ruslan Deianov on 19.07.2025.
//

import Combine
import Darwin
import Foundation

class CPUMonitor: ObservableObject {
    @Published var cpuUsage: Double = 0.0
    @Published var cpuTemperature: Double = 0.0

    private var timer: Timer?
    private var previousIdleTicks: UInt64 = 0
    private var previousTotalTicks: UInt64 = 0

    init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startMonitoring() {
        // Update every 0.5 seconds for smooth animation
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateCPUUsage()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func updateCPUUsage() {
        let usage = getCurrentCPUUsage()

        DispatchQueue.main.async { [weak self] in
            self?.cpuUsage = usage
        }
    }

    private func getCurrentCPUUsage() -> Double {
        var cpuInfo: processor_info_array_t!
        var numCpuInfo: mach_msg_type_number_t = 0
        var numCpus: natural_t = 0

        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCpus,
            &cpuInfo,
            &numCpuInfo
        )

        guard result == KERN_SUCCESS else {
            return 0.0
        }

        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(bitPattern: cpuInfo),
                vm_size_t(Int(numCpuInfo) * MemoryLayout<integer_t>.size)
            )
        }

        var totalUser: UInt64 = 0
        var totalSystem: UInt64 = 0
        var totalIdle: UInt64 = 0
        var totalNice: UInt64 = 0

        for i in 0..<Int(numCpus) {
            let cpuLoadInfo = cpuInfo.advanced(by: i * Int(CPU_STATE_MAX))

            totalUser += UInt64(cpuLoadInfo.pointee)
            totalSystem += UInt64(cpuLoadInfo.advanced(by: Int(CPU_STATE_SYSTEM)).pointee)
            totalIdle += UInt64(cpuLoadInfo.advanced(by: Int(CPU_STATE_IDLE)).pointee)
            totalNice += UInt64(cpuLoadInfo.advanced(by: Int(CPU_STATE_NICE)).pointee)
        }

        let totalTicks = totalUser + totalSystem + totalIdle + totalNice
        let idleTicks = totalIdle

        // Calculate CPU usage percentage
        if previousTotalTicks > 0 {
            let totalTicksDelta = totalTicks - previousTotalTicks
            let idleTicksDelta = idleTicks - previousIdleTicks

            if totalTicksDelta > 0 {
                let usage = Double(totalTicksDelta - idleTicksDelta) / Double(totalTicksDelta)

                // Store current values for next calculation
                previousTotalTicks = totalTicks
                previousIdleTicks = idleTicks

                // Smooth the value and clamp between 0 and 1
                return max(0.0, min(1.0, usage))
            }
        }

        // Store initial values
        previousTotalTicks = totalTicks
        previousIdleTicks = idleTicks

        return 0.0
    }

    // Get average CPU usage over multiple cores
    func getAverageCPUUsage() -> Double {
        return cpuUsage
    }

    // Get CPU usage as percentage string
    func getCPUUsageString() -> String {
        return String(format: "%.1f%%", cpuUsage * 100)
    }

    // Get animation speed based on CPU usage
    func getAnimationSpeedForCPU() -> CGFloat {
        // Map CPU usage to animation speed
        // 0% CPU = 0.2x speed (very slow)
        // 50% CPU = 1.0x speed (normal)
        // 100% CPU = 4.0x speed (very fast)

        let baseSpeed: CGFloat = 0.2

        if cpuUsage <= 0.01 {
            // Very low CPU usage - almost stopped
            return 0.1
        } else if cpuUsage <= 0.1 {
            // Low CPU usage - slow walking
            return baseSpeed + CGFloat(cpuUsage) * 0.8
        } else if cpuUsage <= 0.5 {
            // Medium CPU usage - normal to fast walking
            return 1.0 + CGFloat(cpuUsage - 0.1) * 2.5
        } else {
            // High CPU usage - running fast
            return 2.0 + CGFloat(cpuUsage - 0.5) * 4.0
        }
    }
}
