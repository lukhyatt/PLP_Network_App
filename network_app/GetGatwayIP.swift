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


//func gatewayIP(timeout: Duration = .milliseconds(3000),
//               interface: NWInterface.InterfaceType = .wifi) async -> String? {
//
//    await withCheckedContinuation { continuation in
//        let once = OneShot()                       // protects the “done” flag
//        let monitor = NWPathMonitor(requiredInterfaceType: interface)
//
//        /// Finishes exactly once, whichever path (success/timeout) calls first.
//        @Sendable func finish(_ ip: String?) {
//            Task {                                 // hop onto a Task so we can `await`
//                if await once.take() {             // only the *first* caller gets `true`
//                    continuation.resume(returning: ip)
//                    monitor.cancel()
//                }
//            }
//        }
//
//        // ---- Success path ---------------------------------------------------
//        monitor.pathUpdateHandler = { path in
//            if path.status == .satisfied,
//               case let .hostPort(host, _) = path.gateways.first {
//                finish(host.debugDescription)      // e.g. "192.168.0.1"
//            }
//        }
//        monitor.start(queue: .global())
//
//        // ---- Timeout fallback ----------------------------------------------
//        Task {
//            try? await Task.sleep(for: timeout)
//            finish(nil)                            // Wi-Fi still down after `timeout`
//        }
//    }
//}

//public func currentGatewayAddress() async -> String? {
//    await withCheckedContinuation { continuation in
//        let monitor = NWPathMonitor()               // All interfaces
//        let queue    = DispatchQueue(label: "GatewayMonitor")
//
//        monitor.pathUpdateHandler = { path in
//            defer {                                  // Stop as soon as we learn something
//                monitor.cancel()
//            }
//
//            // `gateways` is an [NWEndpoint]; pick the first host/port pair
//            if let endpoint = path.gateways.first,
//               case let .hostPort(host, _) = endpoint {
//
//                // host.debugDescription gives us a plain string IP
//                continuation.resume(returning: host.debugDescription)
//            } else {
//                continuation.resume(returning: nil)
//            }
//        }
//
//        monitor.start(queue: queue)                 // Begin monitoring
//    }
//}

func currentGatewayAddress(timeout: TimeInterval = 3,
                    interface: NWInterface.InterfaceType? = nil) async -> String? {

    await withCheckedContinuation { continuation in
        let monitor = interface.map(NWPathMonitor.init) ?? NWPathMonitor()
        let queue   = DispatchQueue(label: "GatewaySnap")

        // Failsafe timeout so we don’t wait forever
        queue.asyncAfter(deadline: .now() + timeout) {
            monitor.cancel()
            continuation.resume(returning: nil)
        }

        monitor.pathUpdateHandler = { path in
            guard path.status == .satisfied else { return }    // Wait for an active route

            if let gw = path.gateways
                .compactMap({ ep -> String? in
                    if case let .hostPort(host, _) = ep { return host.debugDescription }
                    return nil
                })
                .first {

                monitor.cancel()
                continuation.resume(returning: gw)
            }
        }

        monitor.start(queue: queue)
    }
}


