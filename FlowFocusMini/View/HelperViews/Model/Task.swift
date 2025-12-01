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
    
    init(
        id: UUID = UUID(),
        taskGroup: String,
        projectName: String,
        taskDescription: String,
        startDate: Date,
        endDate: Date,
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.taskGroup = taskGroup
        self.projectName = projectName
        self.taskDescription = taskDescription
        self.startDate = startDate
        self.endDate = endDate
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
    
    // MARK: - Computed Properties
    
    // Computed property to calculate progress percentage
    var progressPercentage: Double {
        let total = endDate.timeIntervalSince(startDate)
        let elapsed = Date().timeIntervalSince(startDate)
        let progress = min(max(elapsed / total, 0), 1)
        return progress * 100
    }
    
    // Check if task is overdue
    var isOverdue: Bool {
        return !isCompleted && Date() > endDate
    }
    
    // Check if task is in progress
    var isInProgress: Bool {
        return !isCompleted && Date() >= startDate && Date() <= endDate
    }
    
    // MARK: - Update Methods
    
    /// Mark task as completed
    func markAsCompleted() {
        self.isCompleted = true
    }
    
    /// Mark task as incomplete
    func markAsIncomplete() {
        self.isCompleted = false
    }
    
    /// Toggle completion status
    func toggleCompletion() {
        self.isCompleted.toggle()
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
}
