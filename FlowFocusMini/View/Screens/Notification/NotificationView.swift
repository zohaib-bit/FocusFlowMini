//
//  NotificationView.swift
//  FlowFocusMini
//
//  Created by o9tech on 05/12/2025.
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss)  var dismiss
    @EnvironmentObject var notificationVM: NotificationViewModel
    @Environment(\.modelContext)  var modelContext
    
    var body: some View {
        ZStack {
            Background()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Header(dismiss: dismiss)
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                
                if notificationVM.notifications.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "bell.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No Notifications")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Text("You're all caught up!")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.7))
                        
                        Spacer()
                    }
                } else {
                    VStack(spacing: 0) {
                        HStack {
                            Text("\(notificationVM.notifications.count) Notifications")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                ForEach(notificationVM.notifications, id: \.id) { notification in
                                    NotificationRow(notification: notification, viewModel: notificationVM)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top, 50)
        }
        .navigationBarHidden(true)
        .onAppear {
            notificationVM.setModelContext(modelContext)
        }
    }
    
   
}

// MARK: - Notification Row
private struct NotificationRow: View {
    let notification: AppNotification
    let viewModel: NotificationViewModel
    
    var body: some View {
        ZStack {
            // Delete button background
            HStack {
                Spacer()
                Button(action: deleteNotification) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white)
                        .frame(width: 70)
                }
            }
            
            // Main content
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: getIcon(notification.type))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(getIconColor(notification.type))
                    .frame(width: 40, height: 40)
                    .background(getIconColor(notification.type).opacity(0.15))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notification.title)
                            .font(.system(size: 16, weight: .semibold))
                        
                        if !notification.isRead {
                            Circle()
                                .fill(Color.appPrimary)
                                .frame(width: 8, height: 8)
                        }
                        
                        Spacer()
                    }
                    
                    Text(notification.message)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    if let taskName = notification.taskName {
                        Text(taskName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.appPrimary)
                    }
                    
                    Text(getTimeAgo(notification.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(12)
            .background(notification.isRead ? Color.white : Color.appPrimary.opacity(0.05))
            .contentShape(Rectangle())
            .onTapGesture {
                if !notification.isRead {
                    markAsRead()
                }
            }
        }
        .frame(height: 100)
        .background(Color.white)
    }
    
    private func deleteNotification() {
        viewModel.deleteNotification(notification)
    }
    
    private func markAsRead() {
        viewModel.markAsRead(notification)
    }
    
    private func getIcon(_ type: NotificationType) -> String {
        switch type {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    private func getIconColor(_ type: NotificationType) -> Color {
        switch type {
        case .success: return Color(red: 0.16, green: 0.68, blue: 0.35)
        case .error: return Color(red: 0.92, green: 0.31, blue: 0.26)
        case .warning: return Color(red: 1.0, green: 0.58, blue: 0.16)
        case .info: return Color(red: 0.06, green: 0.47, blue: 0.82)
        }
    }
    
    private func getTimeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        else if interval < 3600 { return "\(Int(interval / 60))m ago" }
        else if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        else { return "\(Int(interval / 86400))d ago" }
    }
}

// MARK: - Background
private struct Background: View {
    var body: some View {
        Image("bg_home")
            .resizable()
            .scaledToFill()
    }
}

// MARK: - Header
private struct Header: View {
    let dismiss: DismissAction
    
    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image("ic_arrow")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 12)
            }
            
            Spacer()
            
            Text("Notifications")
                .font(.system(size: 22, weight: .bold))
            
            Spacer()
            
            Circle()
                .fill(Color.clear)
                .frame(width: 40, height: 40)
        }
    }
}

#Preview {
    NotificationView()
        .environmentObject(NotificationViewModel())
}
