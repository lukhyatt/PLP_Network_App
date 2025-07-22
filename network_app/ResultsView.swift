//
//  ResultsView.swift
//  network_app
//
//  Created by Luke Hyatt on 7/10/25.
//
import SwiftUI
import Network
import SystemConfiguration

struct ResultsView: View {
    var body: some View {
        ZStack {
            // A subtle gradient background is often more professional than a flat color.
            LinearGradient(
                colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // A big, friendly icon to give instant visual feedback.
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)
                    .symbolRenderingMode(.palette) // Allows for multi-color symbols
                    .foregroundStyle(.white, .green) // Color the inner check white and the seal green
                    .shadow(radius: 10)
                
                // The main message with good typography.
                Text(fmessage)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // A secondary, more detailed message.
                Text(message)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(30)
        }
        // This gives our new page a title in the navigation bar.
        .navigationTitle("Test Results")
        // We want the back button to be visible, but the title small.
        .navigationBarTitleDisplayMode(.inline)
    }
}
