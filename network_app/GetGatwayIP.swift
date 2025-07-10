//
//  GetGatwayIP.swift
//  network_app
//
//  Created by Luke Hyatt on 7/10/25.
//

import SwiftUI
import Network
import SystemConfiguration
import Foundation

/// Single-use latch: the first caller of `take()` wins.
///

private actor OneShot {
    private var done = false
    func take() -> Bool {
        guard !done else { return false }
        done = true
        return true
    }
}

@available(iOS 15.0, *)
func gatewayIP(timeout: Duration = .milliseconds(1000),
               interface: NWInterface.InterfaceType = .wifi) async -> String? {

    await withCheckedContinuation { continuation in
        let once = OneShot()                       // protects the “done” flag
        let monitor = NWPathMonitor(requiredInterfaceType: interface)

        /// Finishes exactly once, whichever path (success/timeout) calls first.
        @Sendable func finish(_ ip: String?) {
            Task {                                 // hop onto a Task so we can `await`
                if await once.take() {             // only the *first* caller gets `true`
                    continuation.resume(returning: ip)
                    monitor.cancel()
                }
            }
        }

        // ---- Success path ---------------------------------------------------
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied,
               case let .hostPort(host, _) = path.gateways.first {
                finish(host.debugDescription)      // e.g. "192.168.0.1"
            }
        }
        monitor.start(queue: .global())

        // ---- Timeout fallback ----------------------------------------------
        Task {
            try? await Task.sleep(for: timeout)
            finish(nil)                            // Wi-Fi still down after `timeout`
        }
    }
}
