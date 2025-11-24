//
//  HomeView.swift
//  FlowFocusMini
//
//  Created by o9tech on 12/11/2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Task.createdAt, order: .reverse) private var allTasks: [Task]
    
    // Computed properties for real-time filtering
    var inProgressTasks: [Task] {
        allTasks.filter { $0.isInProgress }
    }
    
    var completedTasksCount: Int {
        allTasks.filter { $0.isCompleted }.count
    }
    
    var totalTasks: Int {
        allTasks.count
    }
    
    func tasksByGroup(_ group: String) -> [Task] {
        allTasks.filter { $0.taskGroup == group }
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                // Background respects safe area
                Background()
                    .ignoresSafeArea()
                
                VStack {
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            
                            Header()
                                .padding(.horizontal, 20)
                            
                            TodaysTaskCard(
                                totalTasks: totalTasks,
                                completedTasks: completedTasksCount
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 24)
                            
                            InProgressSection(tasks: inProgressTasks)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 24)
                            
                            TaskGroupsSection(
                                allTasks: allTasks,
                                tasksByGroup: tasksByGroup
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120)  // for bottom nav
                        }
                    }
                    .padding(.top,110)  // space below notch
                }
            }
            .navigationBarHidden(true)
        }
    }
}

private struct Background: View {
        var body: some View{
            Image("bg_home")
                .resizable()
                .scaledToFill()
        }
}

private struct Header: View {
    var username: String = "Livia Vaccaro"
    
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            HStack(spacing: 0) {
                // "home" text at top left
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 12) {
                        // Profile Image
                        Image("img_profile")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        
                        // Text Section
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hello!")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                            Text(username)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                    }
                }
                .frame(width: totalWidth * 0.75, alignment: .leading)
                
                // Notification Icon
                Button(action: {}) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                        
                        // Notification dot
                        Circle()
                            .fill(Color.appPrimary) // Purple
                            .frame(width: 8, height: 8)
                            .offset(x: 4, y: -4)
                    }
                }
                .frame(width: totalWidth * 0.25, alignment: .trailing)
            }
        }
        .frame(height: 50)
        
    }
}

struct TodaysTaskCard: View {
    let totalTasks: Int
    let completedTasks: Int
    
    // Calculate today's completion percentage
    var todaysProgress: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
    
    var progressText: String {
        if totalTasks == 0 {
            return "No tasks yet. Add your first task!"
        } else if completedTasks == totalTasks {
            return "All tasks completed! Great job!"
        } else {
            return "Your today's task almost done!"
        }
    }
    
    var body: some View {
        
        GeometryReader { geo in
            HStack(spacing: 16) {
                // Left side - Text and Button
                VStack(alignment: .leading, spacing: 11) {
                    Text(progressText)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    // Show task count
                    Text("\(completedTasks) of \(totalTasks) completed")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                    
                    NavigationLink(destination: Task_Detail()) {
                        Text("View Task")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.appPrimary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(12)
                        
                    }

                }
                .frame(width: geo.size.width * 0.37)
                
                
                // Right side Percentage circle
                ZStack {
                    // Making Background circle
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    // Making Progress circle
                    Circle()
                        .trim(from: 0, to: todaysProgress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: todaysProgress)
                    
                    // Percentage text
                    Text("\(Int(todaysProgress * 100))%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: geo.size.width * 0.35, alignment: .trailing)
                
                // Three dots menu
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .padding(.leading, 8)
            }
            .padding(20)
            .frame(height: 146)
            .background(Color.appPrimary) // Purple
            .cornerRadius(24)
        }
        .frame(height: 146)
    }
}

struct InProgressSection: View {
    let tasks: [Task]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("In Progress")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                if !tasks.isEmpty {
                    Text("\(tasks.count) task\(tasks.count == 1 ? "" : "s")")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            // Task Cards
            if tasks.isEmpty {
                EmptyStateCard(message: "No tasks in progress")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(tasks) { task in
                            TaskCard(task: task)
                        }
                    }
                }
            }
        }
    }
}

struct TaskCard: View {
    let task: Task
    
    var cardColor: Color {
        switch task.taskGroup {
        case "Work":
            return Color(red: 0.85, green: 0.92, blue: 1.0) // Light blue
        case "Personal":
            return Color(red: 1.0, green: 0.95, blue: 0.85) // Light orange
        case "Health":
            return Color(red: 0.85, green: 1.0, blue: 0.90) // Light green
        case "Finance":
            return Color(red: 1.0, green: 0.90, blue: 0.95) // Light pink
        default:
            return Color(red: 0.95, green: 0.95, blue: 0.95) // Light gray
        }
    }
    
    var progressColor: Color {
        switch task.taskGroup {
        case "Work": return .blue
        case "Personal": return .orange
        case "Health": return .green
        case "Finance": return .pink
        default: return .gray
        }
    }
    
    var icon: String {
        switch task.taskGroup {
        case "Work": return "briefcase.fill"
        case "Personal": return "person.fill"
        case "Health": return "heart.fill"
        case "Finance": return "dollarsign.circle.fill"
        default: return "folder.fill"
        }
    }
    
    var iconColor: Color {
        switch task.taskGroup {
        case "Work": return .blue
        case "Personal": return .purple
        case "Health": return .green
        case "Finance": return .pink
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(task.taskGroup)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            
            Text(task.projectName)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(2)
            
            // Progress Bar
            GeometryReader { progressGeo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: progressGeo.size.width * (task.progressPercentage / 100), height: 6)
                        .animation(.easeInOut(duration: 0.3), value: task.progressPercentage)
                }
            }
            .frame(height: 6)
            
            Text("\(Int(task.progressPercentage))%")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(progressColor)
        }
        .padding(16)
        .frame(width: 200, height: 140)
        .background(cardColor)
        .cornerRadius(20)
    }
}

struct TaskGroupsSection: View {
    let allTasks: [Task]
    let tasksByGroup: (String) -> [Task]
    let groups = ["Work", "Personal", "Health", "Finance"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("Task Groups")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Show total tasks across all groups
                Text("\(allTasks.count) total")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            // Task Group Cards - Show ALL groups with counts
            VStack(spacing: 12) {
                ForEach(groups, id: \.self) { group in
                    let groupTasks = tasksByGroup(group)
                    TaskGroupCard(
                        title: group,
                        tasks: groupTasks
                    )
                }
            }
        }
    }
}

struct TaskGroupCard: View {
    let title: String
    let tasks: [Task]
    
    var taskCount: Int {
        tasks.count
    }
    
    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        let completed = tasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(tasks.count)
    }
    
    var icon: String {
        switch title {
        case "Work": return "briefcase.fill"
        case "Personal": return "person.fill"
        case "Health": return "heart.fill"
        case "Finance": return "dollarsign.circle.fill"
        default: return "folder.fill"
        }
    }
    
    var iconColor: Color {
        switch title {
        case "Work": return .blue
        case "Personal": return .purple
        case "Health": return .green
        case "Finance": return .orange
        default: return .gray
        }
    }
    
    var progressColor: Color {
        iconColor
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                // Show "0 Tasks" even if empty
                Text("\(taskCount) Task\(taskCount == 1 ? "" : "s")")
                    .font(.system(size: 14))
                    .foregroundColor(taskCount == 0 ? .gray.opacity(0.6) : .gray)
            }
            
            Spacer()
            
            // Progress Circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(progressColor.opacity(0.2), lineWidth: 6)
                    .frame(width: 50, height: 50)
                
                // Progress circle - only show if there are tasks
                if taskCount > 0 {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(progressColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
                
                // Percentage text
                Text(taskCount > 0 ? "\(Int(progress * 100))%" : "0%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(taskCount > 0 ? progressColor : .gray.opacity(0.6))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        .opacity(taskCount == 0 ? 0.6 : 1.0) // Dim empty groups slightly
    }
}

struct EmptyStateCard: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Task.self, inMemory: true)
}
