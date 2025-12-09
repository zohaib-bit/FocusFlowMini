
//
//  ToastNotificationView.swift
//  FlowFocusMini
//
//  Created by o9tech on 05/12/2025.
//

import SwiftUI

struct ToastNotificationView: View {
    let notification: AppNotification
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // Icon based on type
                Image(systemName: getIconName(for: notification.type))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(notification.message)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                    
                    if let taskName = notification.taskName {
                        Text(taskName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                }
            }
        }
        .padding(16)
        .background(getBackgroundColor(for: notification.type))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Helper Methods
    
    private func getBackgroundColor(for type: NotificationType) -> Color {
        switch type {
        case .success:
            return Color(red: 0.16, green: 0.68, blue: 0.35) // Green
        case .error:
            return Color(red: 0.92, green: 0.31, blue: 0.26) // Red
        case .warning:
            return Color(red: 1.0, green: 0.58, blue: 0.16) // Orange
        case .info:
            return Color(red: 0.06, green: 0.47, blue: 0.82) // Blue
        }
    }
    
    private func getIconName(for type: NotificationType) -> String {
        switch type {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        case .warning:
            return "exclamationmark.circle.fill"
        case .info:
            return "info.circle.fill"
        }
    }
}

#Preview {
    ToastNotificationView(
        notification: AppNotification(
            title: "Task Created",
            message: "Your task has been saved successfully",
            type: .success,
            taskName: "Design Homepage"
        ),
        onDismiss: {}
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
