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
    @Published var savedInterestsCount = 0  // Track saved interests
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Save user interests to SwiftData
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
                print("DEBUG: Updated existing interests for user \(userId)")
            } else {
                // Create new interests record
                let newInterests = UserInterests(userId: userId, interests: interests)
                modelContext.insert(newInterests)
                print("DEBUG: Created new interests record for user \(userId)")
            }
            
            try modelContext.save()
            self.savedInterestsCount = interests.count
            self.isInterestsSaved = true
            print("DEBUG: Successfully saved \(interests.count) interests")
            isLoading = false
            
        } catch {
            errorMessage = "Failed to save interests: \(error.localizedDescription)"
            print("DEBUG: Error saving interests - \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    // Fetch user interests from SwiftData
    func fetchUserInterests(userId: String) {
        do {
            let descriptor = FetchDescriptor<UserInterests>(
                predicate: #Predicate { $0.userId == userId }
            )
            let interests = try modelContext.fetch(descriptor)
            self.userInterests = interests.first
        } catch {
            errorMessage = "Failed to fetch interests: \(error.localizedDescription)"
        }
    }
    
    // Get interests as array
    func getInterestsArray(userId: String) -> [String] {
        do {
            let descriptor = FetchDescriptor<UserInterests>(
                predicate: #Predicate { $0.userId == userId }
            )
            let interests = try modelContext.fetch(descriptor)
            return interests.first?.interests ?? []
        } catch {
            return []
        }
    }
}
