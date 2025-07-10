//
//  GetIP.swift
//  network_app
//
//  Created by Luke Hyatt on 7/10/25.
//
import SwiftUI
import Network
import SystemConfiguration
import Foundation


struct IPAddressProvider {
    
    /// A dictionary containing the IP addresses for each network interface.
    /// Example: ["en0/ipv4": "192.168.1.10", "en0/ipv6": "fe80::1c6f..."]
    /// "en0" is typically Wi-Fi.
    /// "pdp_ip0" is typically Cellular.
    public static func getIPAddresses() -> [String: String] {
        var addresses: [String: String] = [:]
        
        // Get a list of all network interfaces on the device.
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [:] }
        guard let firstAddr = ifaddr else { return [:] }
        
        // This defer block ensures that the memory allocated by getifaddrs is freed
        // when the function exits, preventing memory leaks.
        defer { freeifaddrs(ifaddr) }
        
        // Loop through the linked list of interfaces.
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ptr.pointee
            
            // Get the interface name (e.g., "en0" for Wi-Fi).
            let name = String(cString: interface.ifa_name)
            
            // Ensure the interface has a valid address.
            guard let addr = interface.ifa_addr else { continue }
            
            // Check the address family (IPv4 or IPv6).
            if addr.pointee.sa_family == UInt8(AF_INET) { // IPv4
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(addr, socklen_t(addr.pointee.sa_len), &hostname, socklen_t(hostname.count),
                               nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                    let address = String(cString: hostname)
                    addresses["\(name)/ipv4"] = address
                }
            } else if addr.pointee.sa_family == UInt8(AF_INET6) { // IPv6
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(addr, socklen_t(addr.pointee.sa_len), &hostname, socklen_t(hostname.count),
                               nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                    let address = String(cString: hostname)
                    addresses["\(name)/ipv6"] = address
                }
            }
        }
        
        return addresses
    }
    
    /// A convenience method to get the primary IP address for a specific interface.
    /// - Parameter interface: The network interface name (e.g., "en0" for Wi-Fi).
    /// - Returns: The IPv4 address for the given interface, or nil if not found.
    public static func getIPAddress(for interface: String) -> String? {
        let allAddresses = getIPAddresses()
        return allAddresses["\(interface)/ipv4"]
    }
}
