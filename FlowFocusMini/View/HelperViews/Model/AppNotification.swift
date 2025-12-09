

//
//  AppNotification.swift
//  FlowFocusMini
//
//  Created by o9tech on 05/12/2025.
//

import Foundation
import SwiftData

// MARK: - Notification Model
@Model
final class AppNotification {
    var id: String = UUID().uuidString
    var title: String
    var message: String
    var type: NotificationType
    var taskName: String?
    var timestamp: Date = Date()
    var isRead: Bool = false
    
    init(title: String, message: String, type: NotificationType, taskName: String? = nil) {
        self.title = title
        self.message = message
        self.type = type
        self.taskName = taskName
    }
}

enum NotificationType: String, Codable {
    case success
    case error
    case info
    case warning
}
