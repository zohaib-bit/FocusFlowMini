//
//  TaskViewModel.swift
//  FlowFocusMini
//
//  Created by o9tech on 21/11/2025.
//

import Foundation
import SwiftData
import SwiftUI

final class TaskViewModel: ObservableObject {
    @Published var tasks: [TodoTask] = []
    @Published var errorMessage: String?
    @Published var aiErrorMessage: String?
    @Published var isGeneratingWithAI: Bool = false
    @Published var username: String = "User"
    @Published var email: String = "user@example.com"
    
    private var modelContext: ModelContext?
    private let aiService: AIService
    
    init(modelContext: ModelContext? = nil, apiKey: String) {
        self.modelContext = modelContext
        self.aiService = AIService(apiKey: apiKey)
        self.loadUserData()
        if modelContext != nil {
            fetchTasks()
        }
    }
    
    // Set model context (useful for dependency injection)
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        fetchTasks()
    }
    
    // MARK: - User Data
    
    /// Load user data from UserDefaults
    func loadUserData() {
        if let savedUsername = UserDefaults.standard.string(forKey: "username") {
            self.username = savedUsername
        }
        if let savedEmail = UserDefaults.standard.string(forKey: "email") {
            self.email = savedEmail
        }
    }
    
    /// Save user data to UserDefaults (call this after user logs in)
    func saveUserData(username: String, email: String) {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(email, forKey: "email")
        DispatchQueue.main.async {
            self.username = username
            self.email = email
        }
    }
    
    /// Set user data directly (useful for real-time updates)
    func setUserData(username: String, email: String) {
        self.username = username
        self.email = email
        saveUserData(username: username, email: email)
    }
    
    /// Clear user data on logout
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "email")
        self.username = "User"
        self.email = "user@example.com"
    }
    
    // MARK: - CRUD Operations
    
    func addTask(
        taskGroup: String,
        projectName: String,
        description: String,
        startDate: Date,
        endDate: Date
    ) -> Bool {
        guard let context = modelContext else {
            errorMessage = "Model context not available"
            return false
        }
        
        // Validation
        guard !projectName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Project name is required"
            return false
        }
        
        guard startDate <= endDate else {
            errorMessage = "End date must be after start date"
            return false
        }
        
        let task = TodoTask(
            taskGroup: taskGroup,
            projectName: projectName,
            taskDescription: description,
            startDate: startDate,
            endDate: endDate
        )
        
        context.insert(task)
        
        do {
            try context.save()
            fetchTasks()
            errorMessage = nil
            objectWillChange.send()
            return true
        } catch {
            errorMessage = "Failed to save task: \(error.localizedDescription)"
            return false
        }
    }
    
    func updateTask(_ task: TodoTask) {
        guard let context = modelContext else {
            errorMessage = "Model context not available"
            return
        }
        
        do {
            try context.save()
            fetchTasks()
            errorMessage = nil
            objectWillChange.send()
        } catch {
            errorMessage = "Failed to update task: \(error.localizedDescription)"
        }
    }
    
    func deleteTask(_ task: TodoTask) {
        guard let context = modelContext else { return }
        
        context.delete(task)
        
        do {
            try context.save()
            fetchTasks()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to delete task: \(error.localizedDescription)"
        }
    }
    
    func toggleTaskCompletion(_ task: TodoTask) {
        task.isCompleted.toggle()
        updateTask(task)
    }
    
    // MARK: - AI Task Generation
    
    /// Parse user input with AI and create a task automatically
    func generateTaskFromAI(input: String) async -> Bool {
        guard let context = modelContext else {
            aiErrorMessage = "Model context not available"
            return false
        }
        
        DispatchQueue.main.async {
            self.isGeneratingWithAI = true
            self.aiErrorMessage = nil
        }
        
        do {
            // Call OpenAI to parse the task
            let parsedTask = try await aiService.parseTask(from: input)
            
            // Convert ISO8601 strings to Date
            guard let startDate = ISO8601DateFormatter().date(from: parsedTask.start_date),
                  let endDate = ISO8601DateFormatter().date(from: parsedTask.end_date) else {
                throw NSError(domain: "TaskViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse dates"])
            }
            
            // Create and save the task
            let task = TodoTask(
                taskGroup: parsedTask.task_group,
                projectName: parsedTask.project_name,
                taskDescription: parsedTask.description,
                startDate: startDate,
                endDate: endDate
            )
            
            context.insert(task)
            
            try context.save()
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.fetchTasks()
                self.isGeneratingWithAI = false
                self.aiErrorMessage = nil
            }
            
            return true
            
        } catch {
            DispatchQueue.main.async {
                self.isGeneratingWithAI = false
                self.aiErrorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Fetch Operations
    
    func fetchTasks() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<TodoTask>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            tasks = try context.fetch(descriptor)
            errorMessage = nil
        } catch {
            errorMessage = "Failed to fetch tasks: \(error.localizedDescription)"
            tasks = []
        }
    }
    
    // MARK: - Filtered Queries
    
    var inProgressTasks: [TodoTask] {
        tasks.filter { $0.isInProgress }
    }
    
    var completedTasks: [TodoTask] {
        tasks.filter { $0.isCompleted }
    }
    
    var overdueTasks: [TodoTask] {
        tasks.filter { $0.isOverdue }
    }
    
    func tasksByGroup(_ group: String) -> [TodoTask] {
        tasks.filter { $0.taskGroup == group }
    }
    
    // MARK: - Statistics
    
    var totalTasks: Int {
        tasks.count
    }
    
    var completedTasksCount: Int {
        completedTasks.count
    }
    
    var inProgressTasksCount: Int {
        inProgressTasks.count
    }
    
    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasksCount) / Double(totalTasks) * 100
    }
}
