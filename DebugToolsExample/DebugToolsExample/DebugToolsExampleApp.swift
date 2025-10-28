//
//  DebugToolsExampleApp.swift
//  DebugToolsExample
//
//  Created by Pau on 28/10/25.
//

import SwiftUI
import SwiftUIDebugTools

@main
struct DebugToolsExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .debugEnvironment() // Enable debug tools
        }
    }
}
