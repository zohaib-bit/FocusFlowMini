//
//  HomeView.swift
//  FlowFocusMini
//
//  Created by o9tech on 12/11/2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var interestVM: InterestViewModel
    @Query(sort: \TodoTask.createdAt, order: .reverse) private var allTasks: [TodoTask]
    
    @State private var showInterestPopup = false
    @State private var hasCheckedInterests = false
    
    // Computed properties for real-time filtering
    var inProgressTasks: [TodoTask] {
        allTasks.filter { $0.isInProgress }
    }
    
    var completedTasksCount: Int {
        allTasks.filter { $0.isCompleted }.count
    }
    
    var totalTasks: Int {
        allTasks.count
    }
    
    func tasksByGroup(_ group: String) -> [TodoTask] {
        allTasks.filter { $0.taskGroup == group }
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    // Background respects safe area
                    Background()
                        .ignoresSafeArea()
                    
                    VStack {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                Header(username: authVM.userDisplayName)
                                    .padding(.horizontal, 20)
                                
                                TodaysTaskCard(
                                    totalTasks: totalTasks,
                                    completedTasks: completedTasksCount
                                )
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                                .padding(.bottom, 24)
                                
                                SimpleSuggestionsSection()
                                    .padding(.horizontal, 20)
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
                        .padding(.top, 110)  // space below notch
                    }
                }
                .navigationBarHidden(true)
            }
            
            // Interest Popup Modal - appears after 2 seconds
            if showInterestPopup {
                InterestPopupModal(onDismiss: {
                    showInterestPopup = false
                })
                .environmentObject(authVM)
                .environmentObject(interestVM)
            }
        }
        .onAppear {
            if !hasCheckedInterests {
                hasCheckedInterests = true
                
                // Check if user has interests
                if let userId = authVM.user?.uid {
                    let interests = interestVM.getInterestsArray(userId: userId)
                    
                    // Show popup after 2 seconds if no interests
                    if interests.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            showInterestPopup = true
                        }
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

private struct Header: View {
    var username: String
    
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
                
                // Notification Screen
               
                NavigationLink(destination: NotificationView()) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                        
                        // Notification dot
                        Circle()
                            .fill(Color.appPrimary)
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

private struct TodaysTaskCard: View {
    let totalTasks: Int
    let completedTasks: Int
    
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
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: todaysProgress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: todaysProgress)
                    
                    Text("\(Int(todaysProgress * 100))%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: geo.size.width * 0.35, alignment: .trailing)
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .padding(.leading, 8)
            }
            .padding(20)
            .frame(height: 146)
            .background(Color.appPrimary)
            .cornerRadius(24)
        }
        .frame(height: 146)
    }
}

private struct SimpleSuggestionsSection: View {
    @EnvironmentObject private var interestVM: InterestViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    
    @State private var suggestions: [SuggestedTask] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appPrimary)
                    
                    Text("Suggested Tasks")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
            }
            
            // Loading State
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(.appPrimary)
                    Spacer()
                }
                .frame(height: 110)
            }
            // Suggestions List
            else if !suggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(suggestions) { suggestion in
                            SuggestionCard(suggestion: suggestion)
                        }
                    }
                }
            }
            // Empty State
            else {
                VStack(spacing: 8) {
                    Image(systemName: "lightbulb.slash")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    Text("No suggestions yet")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 110)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(14)
            }
        }
        .onAppear {
            loadSuggestions()
        }
    }
    
    private func loadSuggestions() {
        guard let userId = authVM.user?.uid else { return }
        
        let userInterests = interestVM.getInterestsArray(userId: userId)
        
        guard !userInterests.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                let service = SuggestionService(apiKey: Config.openaiAPIKey)
                let generated = try await service.generateSuggestions(from: userInterests)
                DispatchQueue.main.async {
                    self.suggestions = generated
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}

private struct SuggestionCard: View {
    let suggestion: SuggestedTask
    
    var cardColor: Color {
        switch suggestion.category.lowercased() {
        case "work":
            return Color(red: 0.85, green: 0.92, blue: 1.0)
        case "personal":
            return Color(red: 1.0, green: 0.95, blue: 0.85)
        case "health":
            return Color(red: 0.85, green: 1.0, blue: 0.90)
        case "finance":
            return Color(red: 1.0, green: 0.90, blue: 0.95)
        default:
            return Color(red: 0.95, green: 0.95, blue: 0.95)
        }
    }
    
    var icon: String {
        switch suggestion.category.lowercased() {
        case "work": return "briefcase.fill"
        case "personal": return "person.fill"
        case "health": return "heart.fill"
        case "finance": return "dollarsign.circle.fill"
        default: return "folder.fill"
        }
    }
    
    var iconColor: Color {
        switch suggestion.category.lowercased() {
        case "work": return .blue
        case "personal": return .purple
        case "health": return .green
        case "finance": return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
                
                Text(suggestion.category)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.gray)
            }
            
            Text(suggestion.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(2)
            
            Text(suggestion.description)
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding(12)
        .frame(width: 160, height: 110)
        .background(cardColor)
        .cornerRadius(14)
    }
}

private struct InProgressSection: View {
    let tasks: [TodoTask]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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

private struct TaskCard: View {
    let task: TodoTask
    
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

private struct TaskGroupsSection: View {
    let allTasks: [TodoTask]
    let tasksByGroup: (String) -> [TodoTask]
    let groups = ["Work", "Personal", "Health", "Finance"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Task Groups")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(allTasks.count) total")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
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

private struct TaskGroupCard: View {
    let title: String
    let tasks: [TodoTask]
    
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
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text("\(taskCount) Task\(taskCount == 1 ? "" : "s")")
                    .font(.system(size: 14))
                    .foregroundColor(taskCount == 0 ? .gray.opacity(0.6) : .gray)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(progressColor.opacity(0.2), lineWidth: 6)
                    .frame(width: 50, height: 50)
                
                if taskCount > 0 {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(progressColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
                
                Text(taskCount > 0 ? "\(Int(progress * 100))%" : "0%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(taskCount > 0 ? progressColor : .gray.opacity(0.6))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        .opacity(taskCount == 0 ? 0.6 : 1.0)
    }
}

private struct EmptyStateCard: View {
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
        .modelContainer(for: TodoTask.self, inMemory: true)
        .environmentObject(AuthViewModel())
        .environmentObject(InterestViewModel(modelContext: ModelContext(try! ModelContainer(for: UserInterests.self))))
}
