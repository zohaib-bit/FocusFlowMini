
//
//  HomeView.swift
//  FlowFocusMini
//
//  Created by o9tech on 12/11/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            
            // Background respects safe area
            Background()
                .ignoresSafeArea()
            
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        Header()
                            .padding(.horizontal, 20)
                        
                        TodaysTaskCard()
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 24)
                        
                        InProgressSection()
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        
                        TaskGroupsSection()
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
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 16) {
                // Left side - Text and Button
                VStack(alignment: .leading, spacing: 11) {
                    Text("Your today's task almost done!")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Button(action: {}) {
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
                        .trim(from: 0, to: 0.85)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    // Percentage text
                    Text("85%")
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
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("In Progress")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
           
            }
            
            // Task Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    TaskCard(
                        projectType: "Office Project",
                        taskTitle: "Grocery shopping app design",
                        progress: 0.75,
                        cardColor: Color(red: 0.85, green: 0.92, blue: 1.0), // Light blue
                        progressColor: Color.blue,
                        icon: "briefcase.fill",
                        iconColor: Color.pink
                    )
                    
                    TaskCard(
                        projectType: "Personal Project",
                        taskTitle: "Uber Eats redesign challenge",
                        progress: 0.55,
                        cardColor: Color(red: 1.0, green: 0.95, blue: 0.85), // Light orange
                        progressColor: Color.orange,
                        icon: "person.fill",
                        iconColor: Color.purple
                    )
                }
            }
        }
    }
}

struct TaskCard: View {
    let projectType: String
    let taskTitle: String
    let progress: Double
    let cardColor: Color
    let progressColor: Color
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(projectType)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            
            Text(taskTitle)
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
                        .frame(width: progressGeo.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .frame(width: 200, height: 126)
        .background(cardColor)
        .cornerRadius(20)
    }
}

struct TaskGroupsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("Task Groups")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
           
            }
            
            // Task Group Cards
            VStack(spacing: 12) {
                TaskGroupCard(
                    title: "Office Project",
                    taskCount: 23,
                    progress: 0.70,
                    icon: "briefcase.fill",
                    iconColor: Color.pink,
                    progressColor: Color.pink
                )
                
                TaskGroupCard(
                    title: "Personal Project",
                    taskCount: 30,
                    progress: 0.52,
                    icon: "person.fill",
                    iconColor: Color.purple,
                    progressColor: Color.purple
                )
                
                TaskGroupCard(
                    title: "Daily Study",
                    taskCount: 30,
                    progress: 0.87,
                    icon: "book.fill",
                    iconColor: Color.orange,
                    progressColor: Color.orange
                )
            }
        }
    }
}

struct TaskGroupCard: View {
    let title: String
    let taskCount: Int
    let progress: Double
    let icon: String
    let iconColor: Color
    let progressColor: Color
    
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
                Text("\(taskCount) Tasks")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Progress Circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(progressColor.opacity(0.2), lineWidth: 6)
                    .frame(width: 50, height: 50)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(progressColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                // Percentage text
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(progressColor)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}


#Preview {
    HomeView()
}
