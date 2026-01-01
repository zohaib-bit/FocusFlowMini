//
//  TodoTask.swift
//  FlowFocusMini
//
//  Created by o9tech on 21/11/2025.
//

import Foundation
import SwiftData

@Model
final class TodoTask {
    var id: UUID
    var taskGroup: String
    var projectName: String
    var taskDescription: String
    var startDate: Date
    var endDate: Date
    var isCompleted: Bool
    var createdAt: Date
    
    // MARK: - New Writable Properties for Status Management
    var completionStatus: String = "todo"
    var progressPercentageValue: Double = 0
    
    init(
        id: UUID = UUID(),
        taskGroup: String,
        projectName: String,
        taskDescription: String,
        startDate: Date,
        endDate: Date,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        completionStatus: String = "todo",
        progressPercentageValue: Double = 0
    ) {
        self.id = id
        self.taskGroup = taskGroup
        self.projectName = projectName
        self.taskDescription = taskDescription
        self.startDate = startDate
        self.endDate = endDate
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completionStatus = completionStatus
        self.progressPercentageValue = progressPercentageValue
    }
    
    // MARK: - Computed Properties
    
    /// Get progress percentage (use the manually set value or calculate from time)
    var progressPercentage: Double {
        // If user has explicitly set progress, use that
        if progressPercentageValue > 0 {
            return progressPercentageValue
        }
        
        // Otherwise, calculate based on time elapsed
        let total = endDate.timeIntervalSince(startDate)
        let elapsed = Date().timeIntervalSince(startDate)
        let progress = min(max(elapsed / total, 0), 1)
        return progress * 100
    }
    
    /// Check if task is overdue
    var isOverdue: Bool {
        return !isCompleted && Date() > endDate
    }
    
    /// Check if task is in progress based on completionStatus
    var isInProgress: Bool {
        return completionStatus == "inProgress"
    }
    
    // MARK: - Update Methods
    
    /// Mark task as completed and set progress to 100%
    func markAsCompleted() {
        self.isCompleted = true
        self.completionStatus = "completed"
        self.progressPercentageValue = 100
    }
    
    /// Mark task as in progress
    func markAsInProgress() {
        self.isCompleted = false
        self.completionStatus = "inProgress"
        self.progressPercentageValue = max(self.progressPercentageValue, 50)
    }
    
    /// Mark task as to do
    func markAsToDo() {
        self.isCompleted = false
        self.completionStatus = "todo"
        self.progressPercentageValue = 0
    }
    
    /// Mark task as incomplete
    func markAsIncomplete() {
        self.isCompleted = false
        self.completionStatus = "todo"
    }
    
    /// Toggle completion status
    func toggleCompletion() {
        self.isCompleted.toggle()
        if self.isCompleted {
            markAsCompleted()
        } else {
            markAsIncomplete()
        }
    }
    
    /// Update task group
    func updateGroup(_ group: String) {
        self.taskGroup = group
    }
    
    /// Update project name
    func updateProjectName(_ name: String) {
        self.projectName = name
    }
    
    /// Update description
    func updateDescription(_ desc: String) {
        self.taskDescription = desc
    }
    
    /// Update dates
    func updateDates(start: Date, end: Date) {
        self.startDate = start
        self.endDate = end
    }
    
    /// Update progress percentage manually
    func updateProgress(_ percentage: Double) {
        self.progressPercentageValue = min(max(percentage, 0), 100)
    }
}
