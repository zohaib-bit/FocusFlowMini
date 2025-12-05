//
//  ProfileView.swift
//  FlowFocusMini
//
//  Created by o9tech on 14/11/2025.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    
    @EnvironmentObject private var viewModel: TaskViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var interestVM: InterestViewModel
    @State private var showEditProfile = false
    @State private var showUserInterests = false

    var body: some View {
        NavigationStack{
        ZStack {
            Background()
                .ignoresSafeArea()
            
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        Header()
                            .padding(.horizontal, 20)
                        
                        // Profile Image and User Info from Firebase
                        ProfileImage(
                            username: authVM.userDisplayName,
                            email: authVM.userEmail
                        )
                        .padding(.horizontal, 20)
                        
                        EditBtn {
                            showEditProfile = true
                        }
                        .padding(.horizontal, 20)
                        
                        ProfileMenuList(showUserInterests: $showUserInterests)
                            .padding(.top, 20)
                            .padding(.bottom, 120)
                    }
                }
                .padding(.top, 110)
            }
        }}
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(authVM: authVM, isPresented: $showEditProfile)
        }
        .sheet(isPresented: $showUserInterests) {
            UserInterestsView(isPresented: $showUserInterests)
                .environmentObject(interestVM)
                .environmentObject(authVM)
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
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            HStack(spacing: 0) {
                
                HStack {
                    Image("ic_arrow")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 28, height: 12)
                }
                .frame(width: totalWidth * 0.33, alignment: .leading)
                
                HStack {
                    Text("Profile")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(width: totalWidth * 0.33, alignment: .center)
                
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
                .frame(width: totalWidth * 0.33, alignment: .trailing)
            }
        }
        .frame(height: 40)
        .padding(.top, 10)
    }
}

private struct ProfileImage: View {
    
    let username: String
    let email: String

    var body: some View {
        VStack(spacing: 16) {
            
            Image("img_profile")
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .clipShape(Circle())
            
            Text(username)
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.primary)

            Text(email)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .padding(.top, 5)
        }
        .padding(.vertical, 20)
    }
}

private struct EditBtn: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Edit")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7)
                .background(Color.appPrimary)
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
    }
}
// MARK: - User Interests View (FIXED)
struct UserInterestsView: View {
    @EnvironmentObject private var interestVM: InterestViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @Binding var isPresented: Bool
    @State private var userInterests: [String] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            // Clean background color instead of image
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                CustomSheetHeader(
                    title: "My Interests",
                    onClose: { isPresented = false }
                )
                
                // Content
                if isLoading {
                    Spacer()
                    ProgressView()
                        .tint(.appPrimary)
                    Spacer()
                } else if userInterests.isEmpty {
                    emptyStateView
                } else {
                    interestsContentView
                }
            }
        }
        .onAppear {
            loadUserInterests()
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.appPrimary.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Interests Yet")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Start by selecting your interests to\npersonalize your experience")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            // Close Button
            Button(action: { isPresented = false }) {
                Text("Close")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.appPrimary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Interests Content
    private var interestsContentView: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Section Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Selected Interests")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("\(userInterests.count) interest\(userInterests.count == 1 ? "" : "s") selected")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Interests Grid using LazyVGrid
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        ForEach(userInterests, id: \.self) { interest in
                            InterestTag(interest: interest)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            
            // Bottom Button
            VStack(spacing: 0) {
                Divider()
                
                Button(action: { isPresented = false }) {
                    Text("Close")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.appPrimary)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(Color(.systemBackground))
        }
    }
    
    private func loadUserInterests() {
        isLoading = true
        
        // Simulate async loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let userId = authVM.user?.uid {
                userInterests = interestVM.getInterestsArray(userId: userId)
            }
            isLoading = false
        }
    }
}

// MARK: - Custom Sheet Header
struct CustomSheetHeader: View {
    let title: String
    var onClose: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .overlay(
            Divider()
                .frame(maxHeight: .infinity, alignment: .bottom)
        )
    }
}

// MARK: - Interest Tag Component (IMPROVED)
struct InterestTag: View {
    let interest: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.appPrimary)
            
            Text(interest)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appPrimary.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.appPrimary.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Updated ProfileMenuList
private struct ProfileMenuList: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var showSignOutAlert = false
    @Binding var showUserInterests: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            
            NavigationRow(icon: "gearshape", title: "Setting") {
                print("Go to settings")
            }
            
            NavigationRow(icon: "person.2", title: "Friend") {
                print("Go to friends")
            }
            
            NavigationRow(icon: "questionmark.bubble", title: "Support") {
                print("Go to support")
            }
            
            Button(action: {
                showUserInterests = true
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.appPrimary.opacity(0.8))
                    
                    Text("My Interests")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    Color.appPrimary.opacity(0.08)
                        .cornerRadius(12)
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            
            NavigationRow(icon: "questionmark.circle", title: "About Us") {
                print("Go to about us")
            }
            
            Button(action: {
                showSignOutAlert = true
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red.opacity(0.8))
                    
                    Text("Sign Out")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    Color.red.opacity(0.08)
                        .cornerRadius(12)
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            
        }
        .cornerRadius(16)
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authVM.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

// MARK: - Navigation Row (Unchanged)
private struct NavigationRow: View {
    var icon: String
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color.appPrimary.opacity(0.8))
                
                Text(title)
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                Color.appPrimary.opacity(0.08)
                    .cornerRadius(12)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }
}



// Edit Profile Sheet
struct EditProfileView: View {
    @ObservedObject var authVM: AuthViewModel
    @Binding var isPresented: Bool
    @State private var tempUsername: String = ""
    @State private var tempEmail: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Form {
                        Section("Display Name") {
                            TextField("Enter name", text: $tempUsername)
                        }
                        
                        Section("Email") {
                            TextField("Enter email", text: $tempEmail)
                                .keyboardType(.emailAddress)
                                .disabled(true)
                        }
                    }
                    
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.appPrimary)
                            .cornerRadius(12)
                    }
                    .padding()
                    
                    Spacer()
                }
                .navigationTitle("Edit Profile")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            tempUsername = authVM.userDisplayName
            tempEmail = authVM.userEmail
        }
    }
    
    private func saveChanges() {
        Task {
            let changeRequest = authVM.user?.createProfileChangeRequest()
            changeRequest?.displayName = tempUsername
            try? await changeRequest?.commitChanges()
            isPresented = false
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(TaskViewModel(apiKey: Config.openaiAPIKey))
        .environmentObject(AuthViewModel())
}
