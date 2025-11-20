import SwiftUI

struct AddTaskView: View {
    @State private var taskGroup = "Work"
    @State private var projectName = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @State private var showTaskGroupDropdown = false
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    
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
                    VStack(spacing: 16) {
                        
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

                Button(action: {}) {
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
        .gesture(
            TapGesture().onEnded {
                hideKeyboard()
            }
        )
    }
}

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
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            HStack(spacing: 0) {
                
                // Back Arrow
                HStack {
                    Image("ic_arrow")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 28, height: 12)
                }
                .frame(width: totalWidth * 0.33, alignment: .leading)
                
                // Title
                HStack {
                    Text("Add Task")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(width: totalWidth * 0.33, alignment: .center)
                
                // Bell Icon
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
            
            // Dropdown
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
