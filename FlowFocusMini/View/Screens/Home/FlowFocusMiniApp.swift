//
//  FlowFocusMiniApp.swift
//  FlowFocusMini
//
//  Created by o9tech on 11/11/2025.
//



import SwiftUI
import SwiftData

@main
struct FlowFocusMiniApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: Task.self)
    }
}
