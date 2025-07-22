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

//func currentGatewayAddress(timeout: TimeInterval = 3,
//                    interface: NWInterface.InterfaceType? = nil) async -> String? {
//     await withCheckedContinuation { continuation in
//        let monitor = interface.map(NWPathMonitor.init) ?? NWPathMonitor()
//        let queue   = DispatchQueue(label: "GatewaySnap")
//
//        // Failsafe timeout so we don’t wait forever
//        queue.asyncAfter(deadline: .now() + timeout) {
//            monitor.cancel()
//            continuation.resume(returning: nil)
//        }
//
//        monitor.pathUpdateHandler = { path in
//            guard path.status == .satisfied else { return }    // Wait for an active route
//
//            if let gw = path.gateways.compactMap({ ep -> String? in
//                    if case let .hostPort(host, _) = ep { return nil } //original was host.debugDescription
//                    return nil
//                })
//                .first {
//
//                monitor.cancel()
//                continuation.resume(returning: gw)
//            }
//        }
//
//        monitor.start(queue: queue)
//    }
//}

func currentGatewayAddress(
    timeout: TimeInterval = 2,
    interface: NWInterface.InterfaceType? = nil,
    completion: @escaping (String?) -> Void
) {
    let semaphore = DispatchSemaphore(value: 0)
    // 1. Set up the path monitor (for a specific interface, if given).
    let monitor = interface.map(NWPathMonitor.init) ?? NWPathMonitor()
    let queue = DispatchQueue(label: "GatewaySnap")
    var didRespond = false

    // 2. Failsafe: after `timeout` seconds, cancel and call back with nil.
    queue.asyncAfter(deadline: .now() + timeout) {
        guard !didRespond else { return }
        didRespond = true
        monitor.cancel()
        completion(nil)
        semaphore.signal()
    }

    // 3. When we get a valid path, extract the first gateway host.
    monitor.pathUpdateHandler = { path in
        guard path.status == .satisfied, !didRespond else { return }
        if let gw = path.gateways.compactMap({ ep -> String? in
                if case let .hostPort(host, _) = ep {
                    return host.debugDescription
                }
                return nil
            }).first
        {
            didRespond = true
            monitor.cancel()
            completion(gw)
        }
        semaphore.signal()
    }

    // 4. Start monitoring.
    monitor.start(queue: queue)
    semaphore.wait()
}




