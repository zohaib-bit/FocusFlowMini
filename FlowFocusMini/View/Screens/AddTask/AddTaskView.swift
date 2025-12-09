//
// AddTaskView.swift
// FlowFocusMini
//
// Created by o9tech on 21/11/2025.
//

import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject private var viewModel: TaskViewModel
    @EnvironmentObject private var notificationVM: NotificationViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Form fields
    @State private var aiInput: String = ""
    @State private var taskGroup = "Work"
    @State private var projectName = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    // MARK: - UI state
    @State private var showTaskGroupDropdown = false
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var showAIErrorAlert = false
    
    let taskGroups = ["Work", "Personal", "Health", "Finance"]
    
    var body: some View {
        ZStack {
            Background()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Header()
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                
                ScrollView(showsIndicators: false) {
                    VStack() {
                        
                        // ===== AI Input Field
                        aiInputFieldView()
                        
                        // ===== Existing Form Fields
                        TaskGroupDropdown(
                            selectedGroup: $taskGroup,
                            isExpanded: $showTaskGroupDropdown,
                            items: taskGroups
                        )
                        
                        ProjectNameField(projectName: $projectName)
                        
                        DescriptionInputField(description: $description)
                        
                        DatePickerCard(
                            title: "Start Date",
                            date: $startDate,
                            isOpen: $showStartDatePicker
                        )
                        
                        DatePickerCard(
                            title: "End Date",
                            date: $endDate,
                            isOpen: $showEndDatePicker
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                Button(action: saveTask) {
                    Text("Add Project")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.appPrimary)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 90)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        // Success alert for saveTask
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") {
                clearForm()
                dismiss()
            }
        } message: {
            Text("Task added successfully!")
        }

        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Failed to add task")
        }

        .alert("AI Error", isPresented: $showAIErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.aiErrorMessage ?? "Failed to generate task with AI")
        }
        .onAppear {
            if viewModel.tasks.isEmpty {
                viewModel.setModelContext(modelContext)
            }
            notificationVM.setModelContext(modelContext)
        }
    }
    
    // MARK: - AI Input Field View
    @ViewBuilder
    private func aiInputFieldView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI Input")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            TextField("Describe the task (e.g. 'Create Task for client tomorrow 5pm for Marketing project')", text: $aiInput, axis: .vertical)
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
                .lineLimit(3...6)
            
            HStack {
                Spacer()
                Button(action: generateWithAI) {
                    if viewModel.isGeneratingWithAI {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(height: 36)
                            .frame(maxWidth: 140)
                    } else {
                        Text("Generate with AI")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(height: 36)
                            .frame(maxWidth: 140)
                    }
                }
                .disabled(aiInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isGeneratingWithAI)
                .background(viewModel.isGeneratingWithAI ? Color.gray.opacity(0.4) : Color.appPrimary)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Actions
    
    private func generateWithAI() {
        hideKeyboard()
        Task {
            let success = await viewModel.generateTaskFromAI(input: aiInput)
            if success {
                if let newTask = viewModel.tasks.first {
                    taskGroup = newTask.taskGroup
                    projectName = newTask.projectName
                    description = newTask.taskDescription
                    startDate = newTask.startDate
                    endDate = newTask.endDate
                    aiInput = ""
                    
                    // SHOW TOAST NOTIFICATION FOR AI GENERATION
                    notificationVM.showToastNotification(
                        title: "Task Generated",
                        message: "Your AI-generated task is ready!",
                        type: .success,
                        taskName: projectName,
                        duration: 3.0
                    )
                }
            } else {
                showAIErrorAlert = true
            }
        }
    }
    
    private func saveTask() {
        hideKeyboard()
        
        let success = viewModel.addTask(
            taskGroup: taskGroup,
            projectName: projectName,
            description: description,
            startDate: startDate,
            endDate: endDate
        )
        
        if success {
            // SHOW TOAST NOTIFICATION IMMEDIATELY WHEN TASK IS SAVED
            notificationVM.showToastNotification(
                title: "Task Created",
                message: "Your project has been saved successfully!",
                type: .success,
                taskName: projectName,
                duration: 4.0
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showSuccessAlert = true
            }
        } else {
            showErrorAlert = true
        }
    }
    
    private func clearForm() {
        aiInput = ""
        projectName = ""
        description = ""
        taskGroup = "Work"
        startDate = Date()
        endDate = Date()
    }
}

// MARK: - Helpers + Subviews

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            HStack(spacing: 0) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 28, height: 28)
                }
                .frame(width: totalWidth * 0.33, alignment: .leading)

                HStack {
                    Text("Add Task")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(width: totalWidth * 0.33, alignment: .center)
            }
        }
        .frame(height: 40)
        .padding(.top, 10)
    }
}

private struct TaskGroupDropdown: View {
    @Binding var selectedGroup: String
    @Binding var isExpanded: Bool
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Task Group")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
            }

            HStack {
                Text(selectedGroup)
                    .font(.system(size: 18, weight: .semibold))

                Spacer()
            }
            .padding(.top, 4)
            .onTapGesture {
                withAnimation(.spring()) { isExpanded.toggle() }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(items, id: \.self) { group in
                        Text(group)
                            .font(.system(size: 16))
                            .padding(.vertical, 6)
                            .onTapGesture {
                                selectedGroup = group
                                withAnimation { isExpanded = false }
                            }
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

private struct ProjectNameField: View {
    @Binding var projectName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Project Name")
                .font(.system(size: 13))
                .foregroundColor(.secondary)

            TextField("Enter project name...", text: $projectName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

private struct DescriptionInputField: View {
    @Binding var description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.system(size: 13))
                .foregroundColor(.secondary)

            TextEditor(text: $description)
                .frame(height: 120)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .scrollContentBackground(.hidden)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

private struct DatePickerCard: View {
    let title: String
    @Binding var date: Date
    @Binding var isOpen: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.secondary)

            HStack {
                Text(formattedDate(date))
                    .font(.system(size: 18, weight: .semibold))

                Spacer()

                Image(systemName: "calendar")
                    .font(.system(size: 22))
            }
            .onTapGesture { withAnimation { isOpen.toggle() } }

            if isOpen {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM, yyyy"
        return f.string(from: date)
    }
}
