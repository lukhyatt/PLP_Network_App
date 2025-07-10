//
//  dnsPing.swift
//  network_app
//
//  Created by Luke Hyatt on 7/10/25.
//

import SwiftUI
import Network
import SystemConfiguration
import Foundation

//PINGING THE DNS, SAME AS THE GATEWAY, JUST WITH DNS

private actor OneShotV2 {
    private var done = false
    func take() -> Bool {
        guard !done else { return false }
        done = true
        return true
    }
}

// MARK: - Public API -----------------------------------------------------------

/// Returns the primary DNS server IP (e.g. "8.8.8.8") **or** `nil`
/// if Wi-Fi is down, unsatisfied, or no DNS config arrives within `timeout`.
@available(iOS 15.0, *)
func dnsServerIP(
    timeout: Duration = .milliseconds(500),
    interface: NWInterface.InterfaceType = .wifi
) async -> String? {

    await withCheckedContinuation { continuation in
        let once    = OneShotV2()
        let monitor = NWPathMonitor(requiredInterfaceType: interface)

        @Sendable func finish(_ ip: String?) {
            Task {
                if await once.take() {
                    continuation.resume(returning: ip)
                    monitor.cancel()
                }
            }
        }

        // — Success path: Wi-Fi is up, grab DNS immediately
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                finish(fetchPrimaryDNSServer())
            }
        }
        monitor.start(queue: .global(qos: .utility))

        // — Timeout fallback
        Task {
            try? await Task.sleep(for: timeout)
            finish(nil)
        }
    }
}

/// Peeks into the dynamic store to get the first DNS server address.
/// The “State:/Network/Global/DNS” key holds a dictionary with kSCPropNetDNSServerAddresses.
private func fetchPrimaryDNSServer() -> String? {
    guard
      let store   = SCDynamicStoreCreate(nil, "DNSQuery" as CFString, nil, nil),
      let dnsDict = SCDynamicStoreCopyValue(store,
                     "State:/Network/Global/DNS" as CFString) as? [String:Any],
      let addrs   = dnsDict[kSCPropNetDNSServerAddresses as String] as? [String],
      let first   = addrs.first
    else {
      return nil
    }
    return first
}
