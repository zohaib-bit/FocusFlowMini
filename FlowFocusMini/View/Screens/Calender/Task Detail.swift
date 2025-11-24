//
//  Task Detail.swift
//  FlowFocusMini
//
//  Created by o9tech on 21/11/2025.
//

import SwiftUI
import SwiftData

struct Task_Detail: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Task.createdAt, order: .reverse) private var allTasks: [Task]
    
    @State private var selectedFilter: TaskFilter = .all
    @State private var searchText = ""
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case todo = "To Do"
        case inProgress = "In Progress"
        case completed = "Completed"
        case overdue = "Overdue"
    }
    
    // Filter tasks based on selected filter and search
    var filteredTasks: [Task] {
        var tasks = allTasks
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break // Show all
        case .todo:
            tasks = tasks.filter { !$0.isInProgress && !$0.isCompleted && !$0.isOverdue }
        case .inProgress:
            tasks = tasks.filter { $0.isInProgress }
        case .completed:
            tasks = tasks.filter { $0.isCompleted }
        case .overdue:
            tasks = tasks.filter { $0.isOverdue }
        }
        
        // Apply search
        if !searchText.isEmpty {
            tasks = tasks.filter { task in
                task.projectName.localizedCaseInsensitiveContains(searchText) ||
                task.taskDescription.localizedCaseInsensitiveContains(searchText) ||
                task.taskGroup.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return tasks
    }
    
    // Group tasks by category
    var tasksByGroup: [String: [Task]] {
        Dictionary(grouping: filteredTasks, by: { $0.taskGroup })
    }
    
    var body: some View {
        ZStack {
            Background()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Header(dismiss: dismiss, taskCount: filteredTasks.count)
                    .padding(.horizontal, 20)
                    .padding(.top, 110)
                
                // Filter Tabs
                FilterTabs(selectedFilter: $selectedFilter)
                    .padding(.top, 20)
                
                // Task List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if filteredTasks.isEmpty {
                            EmptyTasksView(filter: selectedFilter.rawValue)
                                .padding(.top, 60)
                        } else {
                            // Group by task group
                            ForEach(tasksByGroup.keys.sorted(), id: \.self) { group in
                                if let tasks = tasksByGroup[group] {
                                    TaskGroupSection(groupName: group, tasks: tasks)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
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
    let taskCount: Int
    
    var body: some View {
        HStack {
            // Back Button
            Button(action: {
                dismiss()
            }) {
                Image("ic_arrow")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 12)
            }
            
            Spacer()
            
            // Title
            VStack(spacing: 4) {
                Text("All Tasks")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                
                Text("\(taskCount) task\(taskCount == 1 ? "" : "s")")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Placeholder for symmetry
            Circle()
                .fill(Color.clear)
                .frame(width: 40, height: 40)
        }
    }
}


// MARK: - Filter Tabs
private struct FilterTabs: View {
    @Binding var selectedFilter: Task_Detail.TaskFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Task_Detail.TaskFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedFilter = filter
                        }
                    }) {
                        Text(filter.rawValue)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(selectedFilter == filter ? .white : Color.appPrimary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedFilter == filter ? Color.appPrimary : Color.appPrimary.opacity(0.1))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Task Group Section
private struct TaskGroupSection: View {
    let groupName: String
    let tasks: [Task]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Group Header
            HStack {
                Text(groupName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(tasks.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.appPrimary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 4)
            
            // Tasks
            VStack(spacing: 12) {
                ForEach(tasks) { task in
                    DetailTaskCard(task: task)
                }
            }
        }
    }
}

// MARK: - Task Card
private struct DetailTaskCard: View {
    let task: Task
    
    var cardColor: Color {
        switch task.taskGroup {
        case "Work":
            return Color(red: 0.85, green: 0.92, blue: 1.0)
        case "Personal":
            return Color(red: 1.0, green: 0.95, blue: 0.85)
        case "Health":
            return Color(red: 0.85, green: 1.0, blue: 0.90)
        case "Finance":
            return Color(red: 1.0, green: 0.90, blue: 0.95)
        default:
            return Color(red: 0.95, green: 0.95, blue: 0.95)
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
    
    var statusBadge: some View {
        Group {
            if task.isCompleted {
                Label("Completed", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(8)
            } else if task.isOverdue {
                Label("Overdue", systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(8)
            } else if task.isInProgress {
                Label("In Progress", systemImage: "clock.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(8)
            } else {
                Label("To Do", systemImage: "circle")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(8)
            }
        }
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                
                Text(task.taskGroup)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer()
                
                statusBadge
            }
            
            // Task Name
            Text(task.projectName)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(2)
            
            // Description
            if !task.taskDescription.isEmpty {
                Text(task.taskDescription)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            // Date Range
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Text("\(dateFormatter.string(from: task.startDate)) - \(dateFormatter.string(from: task.endDate))")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            // Progress Bar
            if !task.isCompleted {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Progress")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("\(Int(task.progressPercentage))%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(iconColor)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(iconColor.opacity(0.2))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(iconColor)
                                .frame(width: geo.size.width * (task.progressPercentage / 100), height: 6)
                                .animation(.easeInOut(duration: 0.3), value: task.progressPercentage)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Empty State
private struct EmptyTasksView: View {
    let filter: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.4))
            
            Text("No \(filter) Tasks")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Text("Try adjusting your filters or add a new task")
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(Color.white.opacity(0.7))
        .cornerRadius(20)
    }
}

#Preview {
    NavigationStack {
        Task_Detail()
            .modelContainer(for: Task.self, inMemory: true)
    }
}
