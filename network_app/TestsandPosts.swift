//
//  TestsandPosts.swift
//  network_app
//
//  Created by Luke Hyatt on 7/10/25.
//
import SwiftUI
import Network
import SystemConfiguration
import Foundation

func pingTest() {
    Task { // create an async context
        Task {
            currentGatewayAddress(interface: .wifi) { address in
                if let addr = address {
                    print("Gateway is at \(addr)")
                }
                else {
                    print("Timed out or no gateway found")
                }
            }
        }
    }
    //Task {
    //if let dns = await dnsServerIP() {
          //print("DNS → \(dns)")
        //} else {
          //print("No Wi-Fi or no DNS within timeout")
        //}
      //}
    Task{DNSquery(host: "8.8.8.8", domain: "google.com", timeout: 2) {
        
        rtt in
        if let rtt = rtt
        {
            print("DNS ping RTT: \(rtt * 1000) ms")
        }
        else
        {
            print("No response (timed out or network down)")
        }
    }
        Task{
            print(webCheck(website: "https://example.com"))
        }
    }
    
}

func sendLog(
    serial: String,
    level: String,
    srcIP: String,
    srcMAC: String,
    user: String,
    action: String,
    msg: String
) {
    let sep = "~"
    let whaddr = "http://152.26.238.114:7629/incoming"
    
    // 1. Build the payload string
    let whout = [
        serial, level,
        srcIP, srcMAC,
        user, action, msg
    ].joined(separator: sep)
    
    // 2. Base64-encode it
    guard let whoutData = whout.data(using: .utf8) else {
        print("Failed to encode whout string")
        return
    }
    let out64 = whoutData.base64EncodedString()
    
    // 3. Create URLRequest
    guard let url = URL(string: whaddr) else {
        print("Invalid URL: \(whaddr)")
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("text/html", forHTTPHeaderField: "Content-Type")
    request.httpBody = out64.data(using: .utf8)
    
    // 4. Send it
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error sending log:", error)
            return
        }
        if let http = response as? HTTPURLResponse {
            //print("Response status:", http.statusCode)
        }
    }
    task.resume()
}

var message = ""
var fmessage = ""
func post(){
    var ip = ""
    Task { // create an async context
        let ipp = fetchWifiIP() ?? "none"
        ip = ipp
    }
    var listy = ["GatewayIP": true, "DNSquery": true, "Casper Check": true]
    currentGatewayAddress(interface: .wifi) { address in
        if let addr = address {
        }
        else {
            listy["GatewayIP"] = false
        }
    }
    DNSquery(host: "8.8.8.8", domain: "google.com", timeout: 2, ){
        
        rtt in
        if let rtt = rtt
        {
            //print("DNS ping RTT: \(rtt * 1000) ms")
        }
        else
        {
            listy["DNSquery"] = false
        }
    }
    var m = ""
    m = webCheck(website: "https://Casper.pinelakeprep.org:8443")
    if (m != ("Found Jamf Pro in the response!")){
        listy["Casper Check"] = false
    }
    var msg = ""
        //    if (listy["Casper check"] == true) && (listy["pingDNS"] == true){
        //        msg = "all tests passed"
        //    }
        //    else if((listy["Casper check"] == true) && (listy["pingDNS"] == false)){
        //        msg = "dns ping to google failed"
        //    }
        //    else if((listy["Casper check"] == false) && (listy["pingDNS"] == true)){
        //        msg = "get request to Casper failed"
        //    }
        //    else{
        //        msg = "all tests failed"
        //    }
    let q = "Could not reach google"
    let g = "could not reach gateway address"
    let w = "could not reach PLP website"
    let t = ", please show your teacher this message!"
    if (listy["GatewayIP"] == true) && (listy["DNSquery"] == true) && (listy["Casper Check"] == true){
        msg = "All tests successful"
        message = "All tests successful, please show your teacher this message!"
        fmessage = "Your good to go!"
    }
    else if (listy["GatewayIP"] == false) && (listy["DNSquery"] == true) && (listy["Casper Check"] == true){
        msg = "Gateway IP unresponsive"
        message = g + t
        fmessage = "You might have some problems:"
        
        
    }
    else if (listy["GatewayIP"] == false) && (listy["DNSquery"] == false) && (listy["Casper Check"] == true){
        msg = "Gateway address not found and DNS ping to google not responsive"
        message = q + " and " + g + t
        fmessage = "You might have some problems:"
        
    }
    else if (listy["GatewayIP"] == false) && (listy["DNSquery"] == true) && (listy["Casper Check"] == false){
        msg = "Gateway address not found and Casper GET unresponsive"
        message = g + " and " + w + t
        fmessage = "You might have some problems:"
        
    }
    else if (listy["GatewayIP"] == true) && (listy["DNSquery"] == false) && (listy["Casper Check"] == true){
        msg = "DNS ping to google not responsive"
        message = q  + t
        fmessage = "You might have some problems:"
        
    }
    else if (listy["GatewayIP"] == true) && (listy["DNSquery"] == true) && (listy["Casper Check"] == false){
        msg = "Casper GET unresponsive"
        message = w + t
        fmessage = "You might have some problems:"
    }
    else if (listy["GatewayIP"] == true) && (listy["DNSquery"] == false) && (listy["Casper Check"] == false){
        msg = "DNS ping to google unresponsive and Casper GET unresponsive"
        message = q + " and " + w + t
        fmessage = "You might have some problems:"
    }
    else if (listy["GatewayIP"] == false) && (listy["DNSquery"] == false) && (listy["Casper Check"] == false){
        msg = "All tests failed"
        message = "All tests failed, please show your teacher this message!"
        fmessage = "You might have some problems:"
    }
        
        
        sendLog(serial: "111", level: "3",srcIP: String(ip),srcMAC: "placeholder mac address",user: "Network Tester", action: "Network test",msg: msg)
        
    
}
