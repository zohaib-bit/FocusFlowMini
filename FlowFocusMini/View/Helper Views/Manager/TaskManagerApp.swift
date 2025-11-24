//
//  TaskManagerApp.swift
//  FlowFocusMini
//
//  Created by o9tech on 21/11/2025.
//

import SwiftUI
import SwiftData

// ONLY USE THIS IF YOU DON'T HAVE YOUR OWN APP FILE
// Otherwise, just add .modelContainer(for: Task.self) to your existing FlowFocusMiniApp

struct TaskManagerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Task.self)
    }
}

// Main ContentView with TabView
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TaskViewModel(openAIKey: "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")
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            AddTaskView()
                .tabItem {
                    Label("Add Task", systemImage: "plus.circle.fill")
                }
            
            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet")
                }
        }
        .environmentObject(viewModel)
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }
}
