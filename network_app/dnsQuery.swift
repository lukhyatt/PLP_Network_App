//
//  dnsQuery.swift
//  network_app
//
//  Created by Luke Hyatt on 7/10/25.
//

import SwiftUI
import Network
import SystemConfiguration
import Foundation


/// Builds a minimal DNS “A” query for the given domain.
func buildDNSQuery(for domain: String) -> Data {
    var d = Data()
    // 1. Transaction ID (random 16-bit)
    let txID = UInt16.random(in: 0...UInt16.max)
    d.append(contentsOf: [UInt8(txID >> 8), UInt8(txID & 0xff)])
    // 2. Flags: standard recursive query (0x0100)
    d.append(contentsOf: [0x01, 0x00])
    // 3. QDCOUNT = 1, ANCOUNT/NSCOUNT/ARCOUNT = 0
    d.append(contentsOf: [0x00, 0x01, 0x00, 0x00, 0x00, 0x00])
    // 4. QNAME (labels + zero)
    for label in domain.split(separator: ".") {
        guard let len = UInt8(exactly: label.count) else { continue }
        d.append(len)
        d.append(contentsOf: label.utf8)
    }
    d.append(0)
    // 5. QTYPE = A (0x0001), QCLASS = IN (0x0001)
    d.append(contentsOf: [0x00, 0x01, 0x00, 0x01])
    return d
}

/// “Pings” the DNS server at `host` by sending a DNS query for `domain`.
/// - Parameters:
///   - host: DNS server IP (e.g. “8.8.8.8”)
///   - domain: any domain to look up (e.g. “example.com”)
///   - timeout: how long to wait (in seconds) before giving up
///   - completion: called with the RTT in seconds if successful, or `nil` on failure/time-out
func pingDNS(
  host: String = "8.8.8.8",
  domain: String = "google.com",
  timeout: TimeInterval = 5,
  completion: @escaping (TimeInterval?) -> Void
) {
  // 1) Build endpoint & port
  let endpoint = NWEndpoint.Host(host)
  guard let port53 = NWEndpoint.Port(rawValue: 53) else {
    completion(nil)
    return
  }

  // 2) Create connection and query, start timer
  let conn = NWConnection(host: endpoint, port: port53, using: .udp)
  let query = buildDNSQuery(for: domain)
  let start = Date()

  // 3) “Only once” guard
  var didComplete = false
  let finish: (TimeInterval?) -> Void = { rtt in
    guard !didComplete else { return }
    didComplete = true
    completion(rtt)
    conn.cancel()
  }

  // 4) Schedule the timeout
  DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
    finish(nil)  // will only fire if nothing else has called finish yet
  }

  // 5) Wire up the send/receive
  conn.stateUpdateHandler = { state in
    if case .ready = state {
      conn.send(content: query, completion: .contentProcessed { sendError in
        if sendError != nil {
          finish(nil)
          return
        }
        conn.receiveMessage { data, context, isComplete, recvError in
          if let d = data, !d.isEmpty, recvError == nil {
            finish(Date().timeIntervalSince(start))
          } else {
            finish(nil)
          }
        }
      })
    }
  }

  // 6) Kick it off
  conn.start(queue: .global())
}

