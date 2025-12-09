//
//  NotificationViewModel.swift
//  FlowFocusMini
//
//  Created by o9tech on 05/12/2025.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Notification ViewModel
@MainActor
class NotificationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var notifications: [AppNotification] = []
    @Published var toastNotification: AppNotification?
    @Published var showToast: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var modelContext: ModelContext?
    private var toastDismissTask: Task<Void, Never>?
    
    // MARK: - Computed Properties
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    var unreadNotifications: [AppNotification] {
        notifications.filter { !$0.isRead }
    }
    
    var successNotifications: [AppNotification] {
        notifications.filter { $0.type == .success }
    }
    
    var errorNotifications: [AppNotification] {
        notifications.filter { $0.type == .error }
    }
    
    var warningNotifications: [AppNotification] {
        notifications.filter { $0.type == .warning }
    }
    
    // MARK: - Initialization
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        if let context = modelContext {
            fetchNotifications()
        }
    }
    
    // MARK: - Context Setup
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        fetchNotifications()
    }
    
    // MARK: - Add Notification (Persistent Storage)
    /// Create and save a notification to persistent storage
    /// - Parameters:
    ///   - title: The notification title
    ///   - message: The notification message
    ///   - type: The notification type (success, error, warning, info)
    ///   - taskName: Optional task name for context
    func addNotification(
        title: String,
        message: String,
        type: NotificationType,
        taskName: String? = nil
    ) {
        guard let context = modelContext else {
            errorMessage = "Model context not available"
            return
        }
        
        let notification = AppNotification(
            title: title,
            message: message,
            type: type,
            taskName: taskName
        )
        
        context.insert(notification)
        
        do {
            try context.save()
            fetchNotifications()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save notification: \(error.localizedDescription)"
            print("Error saving notification: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Show Toast Notification (Temporary)
    /// Show a temporary toast notification that auto-dismisses
    /// - Parameters:
    ///   - title: The notification title
    ///   - message: The notification message
    ///   - type: The notification type
    ///   - taskName: Optional task name for context
    ///   - duration: How long to display the toast (default: 3.0 seconds)
    func showToastNotification(
        title: String,
        message: String,
        type: NotificationType,
        taskName: String? = nil,
        duration: TimeInterval = 3.0
    ) {
        // Cancel any existing dismiss task
        toastDismissTask?.cancel()
        
        let notification = AppNotification(
            title: title,
            message: message,
            type: type,
            taskName: taskName
        )
        
        // Update UI on main thread
        self.toastNotification = notification
        self.showToast = true
        
        // Auto-dismiss after specified duration
        toastDismissTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            
            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.showToast = false
                    }
                }
            }
        }
        
        // Also save to persistent storage
        addNotification(
            title: title,
            message: message,
            type: type,
            taskName: taskName
        )
    }
    
    // MARK: - Dismiss Toast
    /// Manually dismiss the current toast
    func dismissToast() {
        toastDismissTask?.cancel()
        withAnimation(.easeInOut(duration: 0.3)) {
            showToast = false
        }
    }
    
    // MARK: - Fetch Operations
    /// Fetch all notifications from persistent storage
    func fetchNotifications() {
        guard let context = modelContext else {
            errorMessage = "Model context not available"
            return
        }
        
        let descriptor = FetchDescriptor<AppNotification>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
            notifications = try context.fetch(descriptor)
            errorMessage = nil
        } catch {
            errorMessage = "Failed to fetch notifications: \(error.localizedDescription)"
            notifications = []
            print("Error fetching notifications: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Update Operations
    /// Mark a notification as read
    /// - Parameter notification: The notification to mark as read
    func markAsRead(_ notification: AppNotification) {
        guard let context = modelContext else {
            errorMessage = "Model context not available"
            return
        }
        
        notification.isRead = true
        
        do {
            try context.save()
            fetchNotifications()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to update notification: \(error.localizedDescription)"
            print("Error updating notification: \(error.localizedDescription)")
        }
    }
    
    /// Mark all notifications as read
    func markAllAsRead() {
        guard let context = modelContext else {
            errorMessage = "Model context not available"
            return
        }
        
        for notification in notifications {
            notification.isRead = true
        }
        
        do {
            try context.save()
            fetchNotifications()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to update notifications: \(error.localizedDescription)"
            print("Error updating notifications: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete Operations
    /// Delete a specific notification
    /// - Parameter notification: The notification to delete
    func deleteNotification(_ notification: AppNotification) {
        guard let context = modelContext else {
            errorMessage = "Model context not available"
            return
        }
        
        context.delete(notification)
        
        do {
            try context.save()
            fetchNotifications()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to delete notification: \(error.localizedDescription)"
            print("Error deleting notification: \(error.localizedDescription)")
        }
    }
    
    /// Delete all notifications
    func deleteAllNotifications() {
        guard let context = modelContext else {
            errorMessage = "Model context not available"
            return
        }
        
        for notification in notifications {
            context.delete(notification)
        }
        
        do {
            try context.save()
            fetchNotifications()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to delete all notifications: \(error.localizedDescription)"
            print("Error deleting all notifications: \(error.localizedDescription)")
        }
    }
    
    /// Delete all read notifications
    func deleteReadNotifications() {
        guard let context = modelContext else {
            errorMessage = "Model context not available"
            return
        }
        
        for notification in notifications where notification.isRead {
            context.delete(notification)
        }
        
        do {
            try context.save()
            fetchNotifications()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to delete read notifications: \(error.localizedDescription)"
            print("Error deleting read notifications: \(error.localizedDescription)")
        }
    }
    
    //
}
