//
//  ContentView.swift
//  network_app
//
//  Created by Luke Hyatt on 6/29/25.
//
import SwiftUI
import Network
import SystemConfiguration
import Foundation

enum NavigationRoute: Hashable {
    case results
}

struct ContentView: View {
    @State private var isTesting = false
    
    @State private var navigationPath = [NavigationRoute]()
    @State private var wifiIPAddress: String = "Fetching..."
    
    var body: some View {
        NavigationStack(path: $navigationPath){
            ZStack {
                // MARK: - Background
                Image("PLP_homescreen")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea() // Makes the image go edge-to-edge
                
                // A dark, semi-transparent overlay to improve text readability
                Rectangle()
                    .fill(.black.opacity(0.40))
                    .ignoresSafeArea()
                
                // MARK: - Main Content
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Main Title and Subtitle
                    VStack {
                        Text("Network")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                        Text("Diagnostics")
                            .font(.system(size: 48, weight: .light, design: .rounded))
                            .opacity(0.8)
                    }
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.25), radius: 10, y: 5) // Subtle shadow for depth
                    
                    Spacer()
                    Spacer() // Use two spacers to push the button lower
                    
                    // MARK: - Action Button & Loading Indicator
                    if isTesting {
                        // 2. Show a loading indicator when testing
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5) // Make it a bit larger
                    } else {
                        // 3. The new, professional-looking button
                        Button(action: {
                            performNetworkTest()
                        }) {
                            Label("Begin Test", systemImage: "network")
                                .font(.headline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .background(
                            // A nice gradient instead of a flat color
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.3), radius: 10, y: 10)
                        .transition(.opacity.combined(with: .scale)) // Animate the button's appearance
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 30) // Add horizontal padding to the whole VStack
            }
            // 2. Hide the navigation bar on this home screen for the full-screen effect.
            .toolbar(.hidden, for: .navigationBar)
            // 3. Define the destination for our route.
            .navigationDestination(for: NavigationRoute.self) { route in
                // When a 'results' route is added to the path, show ResultsView.
                if route == .results {
                    ResultsView()
                }
            }
        }
    }
    // MARK: - Functions
        func performNetworkTest() {
            withAnimation {
                isTesting = true
            }

            // Simulate a 1-second network test.
            // Your pingTest() and post() would happen here.
            pingTest()
            //fetchWifiIP()
            post()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // When the test is done:
                // 1. Stop the loading indicator.
                isTesting = false
                
                
                // 2. TRIGGER THE NAVIGATION by adding the 'results' route to our path.
                navigationPath.append(.results)
            }
        }
    /// Fetches the Wi-Fi IP address and updates the state.
        private func fetchWifiIP() {
            // "en0" is the standard interface name for Wi-Fi on iOS devices.
            if let ip = IPAddressProvider.getIPAddress(for: "en0") {
                // When this line runs, SwiftUI detects the change and updates the Text view.
                self.wifiIPAddress = ip
            } else {
                // If Wi-Fi is off or not connected.
                self.wifiIPAddress = "Not Connected"
            }
            print(self.wifiIPAddress)
        }
}


#Preview {
    ContentView()
}
