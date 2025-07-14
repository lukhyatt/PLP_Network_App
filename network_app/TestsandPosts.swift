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
        let ip = await gatewayIP() ?? "none"
        print("Gateway → \(ip)")
    }
    //Task {
    //if let dns = await dnsServerIP() {
          //print("DNS → \(dns)")
        //} else {
          //print("No Wi-Fi or no DNS within timeout")
        //}
      //}
    Task{pingDNS(host: "8.8.8.8", domain: "google.com", timeout: 2) {
        
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
            webCheck(website: "https://Casper.pinelakeprep.org:8443/")
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
            print("ℹ️ Response status:", http.statusCode)
        }
    }
    task.resume()
}


func post(){
    var ip = ""
    Task { // create an async context
        let ipp = await gatewayIP() ?? "none"
        ip = ipp
    }
    var listy = ["DNS": true, "pingDNS": true, "Casper check": true]
    //Task {
        //if (await dnsServerIP()) != nil {
        //}
        //else {
            //listy["DNS"] = false
        //}
      //}
    Task{
        pingDNS(host: "8.8.8.8", domain: "google.com", timeout: 2) {
        
        rtt in
            if rtt == nil
            {
                listy["pingDNS"] = false
            }
        }
    }
    var m = ""
    Task{
        m = webCheck(website: "https://Casper.pinelakeprep.org:8443/")
        if m != ("found \("Jamf Pro") in response!"){
            listy["Casper check"] = false
        }
    }
    var msg = ""
    if (listy["Casper check"] == true) && (listy["pingDNS"] == true){
        msg = "all tests passed"
    }
    else if((listy["Casper check"] == true) && (listy["pingDNS"] == false)){
        msg = "dns ping to google failed"
    }
    else if((listy["Casper check"] == false) && (listy["pingDNS"] == true)){
        msg = "get request to Casper failed"
    }
    else{
        msg = "all tests failed"
    }
    //if listy["DNS"] == true && listy["pingDNS"] == true && listy["Casper Check"] == true{
        //msg = "All tests successful"
        //}
    //else if listy["DNS"] == false && listy["pingDNS"] == true && listy["Casper Check"] == true{
        //msg = "DNS server not found"
        
    //}
    //else if listy["DNS"] == false && listy["pingDNS"] == false && listy["Casper Check"] == true{
       // msg = "DNS server not found and DNS ping to google not responsive"
        
    //}
    //else if listy["DNS"] == false && listy["pingDNS"] == true && listy["Casper Check"] == false{
        //msg = "DNS server not found and Casper GET unresponsive"
        
   // }
    //else if listy["DNS"] == true && listy["pingDNS"] == false && listy["Casper Check"] == true{
        //msg = "DNS ping to google not responsive"
        
    //}
    //else if listy["DNS"] == true && listy["pingDNS"] == true && listy["Casper Check"] == false{
        //msg = "Casper GET unresponsive"
    //}
    //else if listy["DNS"] == true && listy["pingDNS"] == false && listy["Casper Check"] == false{
        //msg = "DNS ping to google unresponsive and Casper GET unresponsive"
    //}
    //else{
        //msg = "all tests failed(ping, pingDNS, Casper GET)"
    //}
    
    
    sendLog(serial: "111", level: "3",srcIP: String(ip),srcMAC: "",user: "Network Tester", action: "Network test",msg: msg)
    
    
}
