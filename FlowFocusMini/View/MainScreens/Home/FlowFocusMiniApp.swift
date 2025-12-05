//
//  FlowFocusMiniApp.swift
//  FlowFocusMini
//
//  Created by o9tech on 11/11/2025.
//

import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct FlowFocusMiniApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let modelContainer: ModelContainer

    @StateObject private var taskVM: TaskViewModel
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(taskVM)
                .environmentObject(authVM)
                .modelContainer(modelContainer)
        }
    }

    init() {
        let schema = Schema([TodoTask.self, UserInterests.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer initialization failed: \(error)")
        }

        let tempVM = TaskViewModel(modelContext: modelContainer.mainContext,
                                   apiKey: Config.openaiAPIKey)
        _taskVM = StateObject(wrappedValue: tempVM)
    }
}
