//
//  Login.swift
//  FlowFocusMini
//
//  Created by o9tech on 25/11/2025.
//


import SwiftUI

struct Login: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Header
                    VStack(spacing: 10) {
                        Image("sigin_heeader_img") // reuse same header for consistency
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .padding(.top, 40)
                        
                        Text("Welcome Back")
                            .font(.system(size: 36, weight: .bold))
                        
                        Text("Log in to continue.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    
                    // MARK: - Form Fields
                    VStack(spacing: 16) {
                        emailField
                        passwordField
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Error Display
                    if !authVM.errorMessage.isEmpty {
                        Text(authVM.errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 13))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // MARK: - Login Button
                    Button {
                        Task {
                            await authVM.signIn(email: email, password: password)
                        }
                    } label: {
                        HStack {
                            if authVM.isLoading {
                                ProgressView()
                            } else {
                                Text("Login")
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "arrow.right")
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(isFormValid ? Color.appPrimary : .gray.opacity(0.3))
                        .cornerRadius(16)
                    }
                    .disabled(!isFormValid || authVM.isLoading)
                    
                    // MARK: - Create Account
                    HStack(spacing: 4) {
                        Text("Don’t have an account?")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        
                        NavigationLink("Sign Up", destination: SignIn())
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.appPrimary)
                    }
                    .padding(.top, 8)
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 30)
            }
            .onTapGesture { hideKeyboard() }
            .navigationBarBackButtonHidden(true)

        }
    }
    
    // MARK: - Components
    
    private var emailField: some View {
        HStack {
            TextField("Valid email", text: $email)
                .font(.system(size: 16))
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
            
            Image(systemName: "envelope")
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(12)
    }
    
    private var passwordField: some View {
        HStack {
            SecureField("Password", text: $password)
                .font(.system(size: 16))
            
            Image(systemName: "lock")
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(12)
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
}

#Preview {
    Login()
        .environmentObject(AuthViewModel())
}
