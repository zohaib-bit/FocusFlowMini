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
    @State private var showInterestPopup = false

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
                        
                        ProfileMenuList(showUserInterests: $showInterestPopup)
                            .padding(.top, 20)
                            .padding(.bottom, 120)
                    }
                }
                .padding(.top, 110)
            }
            
            // MARK: - Interest Popup Modal
            if showInterestPopup {
                EditInterestPopupModal(onDismiss: {
                    showInterestPopup = false
                })
                .environmentObject(authVM)
                .environmentObject(interestVM)
            }
        }}
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(authVM: authVM, isPresented: $showEditProfile)
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

// MARK: - Navigation Row
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

// MARK: - Edit Profile Sheet
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
        .environmentObject(InterestViewModel(modelContext: ModelContext(try! ModelContainer(for: UserInterests.self))))
}
