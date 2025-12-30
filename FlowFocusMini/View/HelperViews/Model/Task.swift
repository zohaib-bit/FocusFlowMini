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
    
<<<<<<< HEAD
    // MARK: - New Writable Properties for Status Management
    var completionStatus: String = "todo"
    var progressPercentageValue: Double = 0
    
=======
>>>>>>> main
    init(
        id: UUID = UUID(),
        taskGroup: String,
        projectName: String,
        taskDescription: String,
        startDate: Date,
        endDate: Date,
        isCompleted: Bool = false,
<<<<<<< HEAD
        createdAt: Date = Date(),
        completionStatus: String = "todo",
        progressPercentageValue: Double = 0
=======
        createdAt: Date = Date()
>>>>>>> main
    ) {
        self.id = id
        self.taskGroup = taskGroup
        self.projectName = projectName
        self.taskDescription = taskDescription
        self.startDate = startDate
        self.endDate = endDate
        self.isCompleted = isCompleted
        self.createdAt = createdAt
<<<<<<< HEAD
        self.completionStatus = completionStatus
        self.progressPercentageValue = progressPercentageValue
=======
>>>>>>> main
    }
    
    // MARK: - Computed Properties
    
<<<<<<< HEAD
    /// Get progress percentage (use the manually set value or calculate from time)
    var progressPercentage: Double {
        // If user has explicitly set progress, use that
        if progressPercentageValue > 0 {
            return progressPercentageValue
        }
        
        // Otherwise, calculate based on time elapsed
=======
    // Computed property to calculate progress percentage
    var progressPercentage: Double {
>>>>>>> main
        let total = endDate.timeIntervalSince(startDate)
        let elapsed = Date().timeIntervalSince(startDate)
        let progress = min(max(elapsed / total, 0), 1)
        return progress * 100
    }
    
<<<<<<< HEAD
    /// Check if task is overdue
=======
    // Check if task is overdue
>>>>>>> main
    var isOverdue: Bool {
        return !isCompleted && Date() > endDate
    }
    
<<<<<<< HEAD
    /// Check if task is in progress based on completionStatus
    var isInProgress: Bool {
        return completionStatus == "inProgress"
=======
    // Check if task is in progress
    var isInProgress: Bool {
        return !isCompleted && Date() >= startDate && Date() <= endDate
>>>>>>> main
    }
    
    // MARK: - Update Methods
    
<<<<<<< HEAD
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
=======
    /// Mark task as completed
    func markAsCompleted() {
        self.isCompleted = true
>>>>>>> main
    }
    
    /// Mark task as incomplete
    func markAsIncomplete() {
        self.isCompleted = false
<<<<<<< HEAD
        self.completionStatus = "todo"
=======
>>>>>>> main
    }
    
    /// Toggle completion status
    func toggleCompletion() {
        self.isCompleted.toggle()
<<<<<<< HEAD
        if self.isCompleted {
            markAsCompleted()
        } else {
            markAsIncomplete()
        }
=======
>>>>>>> main
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
<<<<<<< HEAD
    
    /// Update progress percentage manually
    func updateProgress(_ percentage: Double) {
        self.progressPercentageValue = min(max(percentage, 0), 100)
    }
=======
>>>>>>> main
}
