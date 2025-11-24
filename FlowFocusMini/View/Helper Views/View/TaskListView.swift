//
//  TaskListView.swift
//  FlowFocusMini
//
//  Created by o9tech on 21/11/2025.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject private var viewModel: TaskViewModel
    @State private var selectedFilter: TaskFilter = .all
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case inProgress = "In Progress"
        case completed = "Completed"
        case overdue = "Overdue"
    }
    
    var filteredTasks: [Task] {
        switch selectedFilter {
        case .all:
            return viewModel.tasks
        case .inProgress:
            return viewModel.inProgressTasks
        case .completed:
            return viewModel.completedTasks
        case .overdue:
            return viewModel.overdueTasks
        }
    }
    
    var body: some View {
        ZStack {
            Background()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                TaskListHeader()
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                
                // Filter Pills
                FilterSection(selectedFilter: $selectedFilter)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Task List
                if filteredTasks.isEmpty {
                    EmptyTaskList()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTasks) { task in
                                TaskRowCard(task: task, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

private struct Background: View {
    var body: some View {
        Image("bg_home")
            .resizable()
            .scaledToFill()
    }
}

private struct TaskListHeader: View {
    var body: some View {
        HStack {
            Text("All Tasks")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 22))
                    .foregroundColor(.black)
            }
        }
        .padding(.vertical, 10)
    }
}

private struct FilterSection: View {
    @Binding var selectedFilter: TaskListView.TaskFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TaskListView.TaskFilter.allCases, id: \.self) { filter in
                    FilterPill(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
        }
    }
}

private struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.appPrimary : Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

private struct TaskRowCard: View {
    let task: Task
    let viewModel: TaskViewModel
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: {
                viewModel.toggleTaskCompletion(task)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(task.isCompleted ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Task Info
            VStack(alignment: .leading, spacing: 8) {
                // Project Name
                Text(task.projectName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .strikethrough(task.isCompleted)
                
                // Task Group Badge
                HStack(spacing: 8) {
                    Text(task.taskGroup)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(groupColor(task.taskGroup))
                        .cornerRadius(6)
                    
                    if task.isOverdue {
                        Text("Overdue")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(6)
                    }
                }
                
                // Progress Bar (only for non-completed tasks)
                if !task.isCompleted && task.isInProgress {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.appPrimary)
                                .frame(
                                    width: geometry.size.width * CGFloat(task.progressPercentage / 100),
                                    height: 6
                                )
                        }
                    }
                    .frame(height: 6)
                    
                    Text("\(Int(task.progressPercentage))% complete")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                // Date
                Text(formattedDateRange(task))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Delete Button
            Button(action: {
                showDeleteAlert = true
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 18))
                    .foregroundColor(.red)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .alert("Delete Task", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteTask(task)
            }
        } message: {
            Text("Are you sure you want to delete '\(task.projectName)'?")
        }
    }
    
    private func groupColor(_ group: String) -> Color {
        switch group {
        case "Work": return .blue
        case "Personal": return .purple
        case "Health": return .green
        case "Finance": return .orange
        default: return .gray
        }
    }
    
    private func formattedDateRange(_ task: Task) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return "\(formatter.string(from: task.startDate)) - \(formatter.string(from: task.endDate))"
    }
}

private struct EmptyTaskList: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No tasks found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Add a new task to get started")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
