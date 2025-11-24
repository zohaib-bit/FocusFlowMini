//
// TaskViewModel.swift
// FlowFocusMini
//
// Created by o9tech on 21/11/2025.
//

import Foundation
import SwiftData
import SwiftUI

/// Primary ViewModel for tasks. Observable so SwiftUI updates UI when changes occur.
/// Added AI support: use `generateTaskFromAI(input:)` to parse natural language and save a Task.
final class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var errorMessage: String?

    // Optional AI error / status fields for UI
    @Published var isGeneratingWithAI: Bool = false
    @Published var aiErrorMessage: String?

    private var modelContext: ModelContext?
    private let aiService: AIService

    // Initialize with an API key passed from app / environment.
    init(modelContext: ModelContext? = nil, openAIKey: String) {
        self.modelContext = modelContext
        self.aiService = AIService(apiKey: "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")

        if modelContext != nil {
            fetchTasks()
        }
    }

    // Set or update model context (useful for dependency injection in previews/test)
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        fetchTasks()
    }

    // MARK: - CRUD Operations (unchanged behaviour; comments added)

    /// Add new Task to SwiftData store synchronously from UI input
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

        // Validation checks
        guard !projectName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Project name is required"
            return false
        }

        guard startDate <= endDate else {
            errorMessage = "End date must be after start date"
            return false
        }

        // Create Task (SwiftData @Model object)
        let task = Task(
            taskGroup: taskGroup,
            projectName: projectName,
            taskDescription: description,
            startDate: startDate,
            endDate: endDate
        )

        // Insert and save
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

    func updateTask(_ task: Task) {
        guard let context = modelContext else { return }
        do {
            try context.save()
            fetchTasks()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to update task: \(error.localizedDescription)"
        }
    }

    func deleteTask(_ task: Task) {
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

    func toggleTaskCompletion(_ task: Task) {
        task.isCompleted.toggle()
        updateTask(task)
    }

    // MARK: - Fetch Operations

    func fetchTasks() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Task>(
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

    // MARK: - Filters & Stats (unchanged)
    var inProgressTasks: [Task] {
        tasks.filter { $0.isInProgress }
    }

    var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
    }

    var overdueTasks: [Task] {
        tasks.filter { $0.isOverdue }
    }

    func tasksByGroup(_ group: String) -> [Task] {
        tasks.filter { $0.taskGroup == group }
    }

    var totalTasks: Int { tasks.count }
    var completedTasksCount: Int { completedTasks.count }
    var inProgressTasksCount: Int { inProgressTasks.count }
    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasksCount) / Double(totalTasks) * 100
    }

    // MARK: - AI Integration

    /// Generate a Task from natural language `input` using the AIService and insert into SwiftData.
    /// Returns true on success, false on failure. Updates `aiErrorMessage` for display.
    @MainActor
    func generateTaskFromAI(input: String) async -> Bool {
        guard let context = modelContext else {
            aiErrorMessage = "Model context not available"
            return false
        }

        isGeneratingWithAI = true
        aiErrorMessage = nil

        do {
            // Call AI service
            let parsed = try await aiService.parseTask(from: input)

            // Convert ISO8601 -> Date (try to parse; fallback to now or now+2h)
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            var start = iso.date(from: parsed.start_date)
            if start == nil {
                // try without fractional seconds
                iso.formatOptions = [.withInternetDateTime]
                start = iso.date(from: parsed.start_date)
            }
            let end = iso.date(from: parsed.end_date) ?? start?.addingTimeInterval(7200) ?? Date().addingTimeInterval(7200)
            let startDate = start ?? Date()

            // Validate or sanitize strings
            let tg = parsed.task_group.isEmpty ? "Work" : parsed.task_group
            let pn = parsed.project_name.isEmpty ? "General" : parsed.project_name
            let desc = parsed.description

            // Create Task and save
            let task = Task(
                taskGroup: tg,
                projectName: pn,
                taskDescription: desc,
                startDate: startDate,
                endDate: end
            )

            context.insert(task)
            try context.save()

            // Refresh tasks list and UI
            fetchTasks()
            isGeneratingWithAI = false
            aiErrorMessage = nil
            return true
        } catch {
            aiErrorMessage = "AI error: \(error.localizedDescription)"
            isGeneratingWithAI = false
            return false
        }
    }
}
