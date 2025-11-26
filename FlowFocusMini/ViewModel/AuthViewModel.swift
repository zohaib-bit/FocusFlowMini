//
//  AuthViewModel.swift
//  FlowFocusMini
//
//  Created by o9tech on 25/11/2025.
//

import SwiftUI
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User? = nil
    @Published var isLoading = false
    @Published var errorMessage = ""

    init() {
        self.user = Auth.auth().currentUser
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = ""

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signUp(email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = ""

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
            
            // Set the display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            
            // Update the user reference
            self.user = Auth.auth().currentUser
            
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signOut() {
        try? Auth.auth().signOut()
        self.user = nil
    }
    
    // MARK: - Get User Data
    
    /// Get current user's email
    var userEmail: String {
        return user?.email ?? "No email"
    }
    
    /// Get current user's display name
    var userDisplayName: String {
        return user?.displayName ?? "User"
    }
}
