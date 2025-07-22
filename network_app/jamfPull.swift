//
//  jamfPull.swift
//  network_app
//
//  Created by Luke Hyatt on 7/14/25.
//
//import Network
//import SystemConfiguration
//import Foundation
//
//struct JamfDevice: Decodable {
//    struct Hardware: Decodable { let serialNumber: String }
//    let id: Int
//    let hardware: Hardware
//}
//
//func jamfSerialLookup(serial: String,
//                      server: URL,
//                      token: String) async throws -> JamfDevice? {
//    var url = server
//    url.appendPathComponent("api/v1/mobile-devices-inventory")
//    url.query =
//    var req = URLRequest(url: url)
//    req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//    let (data, _) = try await URLSession.shared.data(for: req)
//    
//    struct Results: Decodable { let results: [JamfDevice] }
//    return try JSONDecoder().decode(Results.self, from: data).results.first
//}
