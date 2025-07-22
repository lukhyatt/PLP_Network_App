//
//  WebGetReq.swift
//  network_app
//
//  Created by Luke Hyatt on 7/10/25.
//
import SwiftUI
import Network
import SystemConfiguration
import Foundation


func webCheck(website: String) -> String{
    let semaphore = DispatchSemaphore(value: 0)
    var s = ""
    if let url = URL(string: website) {
        let request = URLRequest(url: url)
    URLSession(configuration: .default)
        .dataTask(with: request) { (data, response, error) -> Void in
            guard error == nil else {
                //print("Error:", error ?? "")
                s = "Error: " + (error?.localizedDescription ?? "")
                //print(s)
                semaphore.signal()
                return
            }
            guard let data = data else {
                    semaphore.signal()
                    //print("No response data")
                    s = "No response data"
                    print(s)
                    return
                }
                if let bodyText = String(data: data, encoding: .utf8) {
                    let target = "Jamf Pro"    // ← whatever you’re looking for
                        if bodyText.contains(target) {
                            semaphore.signal()
                            s = "Found Jamf Pro in the response!"
                        } else {
                            s = "“\(target)” not found."
                            semaphore.signal()
                        }
                }
                
        }
        .resume()
    }
    semaphore.wait()
    return s
}
