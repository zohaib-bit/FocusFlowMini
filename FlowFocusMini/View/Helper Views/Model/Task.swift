//
//  Task.swift
//  FlowFocusMini
//
//  Created by o9tech on 21/11/2025.
//

import Foundation
import SwiftData

@Model
final class Task {
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
}
