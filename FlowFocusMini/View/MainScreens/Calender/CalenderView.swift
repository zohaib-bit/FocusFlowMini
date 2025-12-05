//
//  CalenderView.swift
//  FlowFocusMini
//
//  Created by o9tech on 14/11/2025.
//

import SwiftUI
import SwiftData

struct CalenderView: View {
    @Query(sort: \TodoTask.createdAt, order: .reverse) private var tasks: [TodoTask]
    
    @State private var selectedDate: Date = {
        let calendar = Calendar.current
        return calendar.startOfDay(for: Date())
    }()
    
    @State private var selectedTab = 0
    
    // Filter tasks by selected date
    var tasksForSelectedDate: [TodoTask] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? selectedDate
        
        return tasks.compactMap { task -> TodoTask? in
            let taskStartDay = calendar.startOfDay(for: task.startDate)
            let taskEndDay = calendar.startOfDay(for: task.endDate)
            
            if startOfDay >= taskStartDay && startOfDay <= taskEndDay {
                return task
            }
            return nil
        }
    }
    
    // Tab filtered
    var filteredTasks: [TodoTask] {
        let dateTasks = tasksForSelectedDate
        
        switch selectedTab {
        case 0: return dateTasks
        case 1: return dateTasks.filter { !$0.isInProgress && !$0.isCompleted }
        case 2: return dateTasks.filter { $0.isInProgress }
        case 3: return dateTasks.filter { $0.isCompleted }
        default: return dateTasks
        }
    }
    
    var body: some View {
        ZStack{
            Background()
                .ignoresSafeArea()
            
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        Header()
                            .padding(.horizontal, 20)
                        
                        DateCarousel(selectedDate: $selectedDate)
                            .padding(.top, 30)
                        
                        TaskFilterTabs(selectedTab: $selectedTab)
                            .padding(.top, 30)
                        
                        TaskListSection(tasks: filteredTasks, selectedDate: selectedDate)
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 120)
                    }
                }
                .padding(.top, 110)
            }
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
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 12) {
                        Image("ic_arrow")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 28, height: 12)
                    }
                }
                .frame(width: totalWidth * 0.33, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Today Task")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                    }
                }
                .frame(width: totalWidth * 0.33, alignment: .center)
                
                Button(action: {}) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                        
                        Circle()
                            .fill(Color.appPrimary)
                            .frame(width: 8, height: 8)
                            .offset(x: 4, y: -4)
                    }
                }
                .frame(width: totalWidth * 0.33, alignment: .trailing)
            }
        }
        .frame(height: 40)
        .padding(.top, 10)
    }
}

private struct DateCarousel: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(generateDates(), id: \.self) { date in
                        DateCard(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        )
                        .id(date)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedDate = date
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        proxy.scrollTo(Date(), anchor: .center)
                    }
                }
            }
        }
    }
    
    private func generateDates() -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        
        let currentYear = calendar.component(.year, from: Date())
        guard let startOfYear = calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1)) else {
            return dates
        }
        
        let daysInYear = calendar.range(of: .day, in: .year, for: Date())?.count ?? 365
        
        for dayOffset in 0..<daysInYear {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfYear) {
                dates.append(date)
            }
        }
        
        return dates
    }
}

private struct DateCard: View {
    let date: Date
    let isSelected: Bool
    
    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(monthString)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
            
            Text(dayString)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(isSelected ? .white : .primary)
            
            Text(weekdayString)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
        }
        .frame(width: 70, height: 110)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color.appPrimary : Color.white.opacity(0.7))
        )
        .shadow(color: isSelected ? Color.appPrimary.opacity(0.3) : Color.black.opacity(0.05),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2)
    }
}

private struct TaskFilterTabs: View {
    @Binding var selectedTab: Int
    let tabs = ["All", "To do", "In Progress", "Completed"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTab = index
                        }
                    }) {
                        Text(tab)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(selectedTab == index ? .white : Color.appPrimary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedTab == index ? Color.appPrimary : Color.appPrimary.opacity(0.1))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct TaskListSection: View {
    let tasks: [TodoTask]
    let selectedDate: Date
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tasks")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(dateString)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if !tasks.isEmpty {
                    Text("\(tasks.count) task\(tasks.count == 1 ? "" : "s")")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.appPrimary.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            
            if tasks.isEmpty {
                EmptyTaskState()
            } else {
                VStack(spacing: 12) {
                    ForEach(tasks) { task in
                        CalendarTaskCard(task: task)
                    }
                }
            }
        }
    }
}

private struct CalendarTaskCard: View {
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
    
    var statusText: String {
        if task.isCompleted {
            return "Completed"
        } else if task.isInProgress {
            return "In Progress"
        } else {
            return "To Do"
        }
    }
    
    var statusColor: Color {
        if task.isCompleted {
            return .green
        } else if task.isInProgress {
            return .orange
        } else {
            return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(task.projectName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(task.taskGroup)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 4, height: 4)
                    
                    Text(statusText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(statusColor)
                }
            }
            
            Spacer()
            
            if !task.isCompleted {
                VStack(spacing: 4) {
                    Text("\(Int(task.progressPercentage))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(iconColor)
                    
                    ProgressView(value: task.progressPercentage, total: 100)
                        .tint(iconColor)
                        .frame(width: 50)
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

private struct EmptyTaskState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.4))
            
            Text("No tasks for this date")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            
            Text("Select a different date or add a new task")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(Color.white.opacity(0.5))
        .cornerRadius(20)
    }
}

#Preview {
    CalenderView()
        .modelContainer(for: TodoTask.self, inMemory: true)
}
