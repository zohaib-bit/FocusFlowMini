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
        .modelContainer(for: TodoTask.self)
    }
}

// Main ContentView with TabView
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TaskViewModel(apiKey: Config.openaiAPIKey)
    
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
