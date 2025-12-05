import SwiftUI

struct SignIn: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var agreedToTerms = false
    @State private var goToLogin = false   // For navigation
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    VStack(spacing: 10) {
                        Image("sigin_heeader_img")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .padding(.top, 40)
                        
                        Text("Get Started")
                            .font(.system(size: 36, weight: .bold))
                        
                        Text("by creating a free account.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    
                    // MARK: - Form Fields
                    VStack(spacing: 16) {
                        
                        customField(icon: "person", placeholder: "Full name", text: $username)
                        customField(icon: "envelope", placeholder: "Valid email", text: $email, email: true)
                        passwordField
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Terms
                    HStack(alignment: .top, spacing: 10) {
                        Button {
                            agreedToTerms.toggle()
                        } label: {
                            Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(agreedToTerms ? Color.appPrimary : .gray.opacity(0.4))
                                .font(.system(size: 22))
                        }
                        
                        Text("By checking the box you agree to our **Terms** and **Conditions**.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    // MARK: - Error Message
                    if !authVM.errorMessage.isEmpty {
                        Text(authVM.errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 13))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // MARK: - Login Button
                    HStack(spacing: 4) {
                        Text("Already a member?")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        
                        NavigationLink("Log In", destination: Login())
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.appPrimary)
                    }
                    .padding(.top, 8)
                    
                    // MARK: - Next Button
                    Button {
                        Task {
                            await authVM.signUp(email: email, password: password, displayName: username)
                        }
                    } label: {
                        HStack {
                            if authVM.isLoading {
                                ProgressView()
                            } else {
                                Text("Next")
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "arrow.right")
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(isFormValid ? Color.appPrimary : Color.gray.opacity(0.3))
                        .cornerRadius(16)
                    }
                    .disabled(!isFormValid || authVM.isLoading)
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 30)
            }
            .onTapGesture { hideKeyboard() }
            .navigationBarBackButtonHidden(true)

        }
    }
    
    
    private func customField(icon: String, placeholder: String, text: Binding<String>, email: Bool = false) -> some View {
        HStack {
            TextField(placeholder, text: text)
                .font(.system(size: 16))
                .textInputAutocapitalization(email ? .never : .words)
                .keyboardType(email ? .emailAddress : .default)
                .autocorrectionDisabled(email)
            
            Image(systemName: icon)
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(12)
    }
    
    private var passwordField: some View {
        HStack {
            SecureField("Strong Password", text: $password)
                .font(.system(size: 16))
            
            Image(systemName: "lock")
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(12)
    }
    
    private var isFormValid: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty && agreedToTerms
    }
}

#Preview {
    SignIn()
        .environmentObject(AuthViewModel())
}

