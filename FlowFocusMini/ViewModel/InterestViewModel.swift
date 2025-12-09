//
//  InterestViewModel.swift
//  FlowFocusMini
//
//  Created by o9tech on 04/12/2025.
//

import Foundation
import SwiftData

// MARK: - SwiftData Model
@Model
final class UserInterests {
    var userId: String
    var interests: [String] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    init(userId: String, interests: [String] = []) {
        self.userId = userId
        self.interests = interests
    }
}

// MARK: - ViewModel (MVVM Pattern)
@MainActor
class InterestViewModel: ObservableObject {
    @Published var userInterests: UserInterests?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isInterestsSaved = false
    @Published var savedInterestsCount = 0
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Save User Interests
    /// Save or update user interests to SwiftData
    func saveUserInterests(_ interests: [String], for userId: String) {
        saveUserInterests(interests, userId: userId)
    }
    
    /// Save user interests (overloaded version)
    func saveUserInterests(_ interests: [String], userId: String) {
        isLoading = true
        errorMessage = ""
        
        do {
            // Check if user interests already exist
            let descriptor = FetchDescriptor<UserInterests>(
                predicate: #Predicate { $0.userId == userId }
            )
            let existingInterests = try modelContext.fetch(descriptor)
            
            if let existing = existingInterests.first {
                // Update existing interests
                existing.interests = interests
                existing.updatedAt = Date()
                print("✅ Updated existing interests for user: \(userId)")
            } else {
                // Create new interests record
                let newInterests = UserInterests(userId: userId, interests: interests)
                modelContext.insert(newInterests)
                print("✅ Created new interests record for user: \(userId)")
            }
            
            try modelContext.save()
            
            // Update published properties
            self.fetchUserInterests(userId: userId)
            self.savedInterestsCount = interests.count
            self.isInterestsSaved = true
            
            print("✅ Successfully saved \(interests.count) interests")
            isLoading = false
            
        } catch {
            errorMessage = "Failed to save interests: \(error.localizedDescription)"
            print("❌ Error saving interests - \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    // MARK: - Fetch User Interests
    /// Fetch user interests from SwiftData
    func fetchUserInterests(userId: String) {
        do {
            let descriptor = FetchDescriptor<UserInterests>(
                predicate: #Predicate { $0.userId == userId }
            )
            let interests = try modelContext.fetch(descriptor)
            self.userInterests = interests.first
            self.savedInterestsCount = interests.first?.interests.count ?? 0
            print("✅ Fetched \(self.savedInterestsCount) interests for user: \(userId)")
        } catch {
            errorMessage = "Failed to fetch interests: \(error.localizedDescription)"
            print("❌ Error fetching interests - \(error.localizedDescription)")
        }
    }
    
    // MARK: - Get Interests Array
    /// Get interests as array for a specific user
    func getInterestsArray(userId: String) -> [String] {
        do {
            let descriptor = FetchDescriptor<UserInterests>(
                predicate: #Predicate { $0.userId == userId }
            )
            let interests = try modelContext.fetch(descriptor)
            return interests.first?.interests ?? []
        } catch {
            print("❌ Error fetching interests array - \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Delete User Interests
    /// Delete all interests for a specific user
    func deleteUserInterests(for userId: String) {
        do {
            let descriptor = FetchDescriptor<UserInterests>(
                predicate: #Predicate { $0.userId == userId }
            )
            
            let interestsToDelete = try modelContext.fetch(descriptor)
            
            for interest in interestsToDelete {
                modelContext.delete(interest)
            }
            
            try modelContext.save()
            self.userInterests = nil
            self.savedInterestsCount = 0
            
            print("✅ Deleted interests for user: \(userId)")
        } catch {
            errorMessage = "Failed to delete interests: \(error.localizedDescription)"
            print("❌ Error deleting interests - \(error.localizedDescription)")
        }
    }
    
    // MARK: - Add Single Interest
    /// Add a single interest to user's interests
    func addInterest(_ interest: String, for userId: String) {
        let currentInterests = getInterestsArray(userId: userId)
        
        if !currentInterests.contains(interest) {
            var updatedInterests = currentInterests
            updatedInterests.append(interest)
            saveUserInterests(updatedInterests, userId: userId)
        }
    }
    
    // MARK: - Remove Single Interest
    /// Remove a single interest from user's interests
    func removeInterest(_ interest: String, for userId: String) {
        let currentInterests = getInterestsArray(userId: userId)
        
        if currentInterests.contains(interest) {
            var updatedInterests = currentInterests
            updatedInterests.removeAll { $0 == interest }
            saveUserInterests(updatedInterests, userId: userId)
        }
    }
    
    // MARK: - Check if Interest Exists
    /// Check if a specific interest is in user's interests
    func hasInterest(_ interest: String, for userId: String) -> Bool {
        let interests = getInterestsArray(userId: userId)
        return interests.contains(interest)
    }
    
    // MARK: - Clear Error
    /// Clear error message
    func clearError() {
        errorMessage = ""
    }
    
    // MARK: - Reset Saved State
    /// Reset the saved state flag
    func resetSavedState() {
        isInterestsSaved = false
    }
}
