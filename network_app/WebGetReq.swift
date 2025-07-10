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
    var s = ""
    if let url = URL(string: website) {
        let request = URLRequest(url: url)
    //request.httpMethod = "HEAD"
    URLSession(configuration: .default)
        .dataTask(with: request) { (data, response, error) -> Void in
            guard error == nil else {
                //print("Error:", error ?? "")
                s = "Error: " + (error?.localizedDescription ?? "")
                return
            }
            guard let data = data else {
                    //print("No response data")
                    s = "No response data"
                    return
                }
                if let bodyText = String(data: data, encoding: .utf8) {
                    let target = "Jamf Pro"    // ← whatever you’re looking for
                        if bodyText.contains(target) {
                            s = "Found “\(target)” in the response!"
                        } else {
                            s = "“\(target)” not found."
                        }
                }
        }
        .resume()
    }
    return s
}
