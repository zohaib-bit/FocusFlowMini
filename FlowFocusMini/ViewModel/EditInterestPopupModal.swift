//
//  EditInterestPopupModal.swift
//  FlowFocusMini
//
//  Created by o9tech on 05/12/2025.
//

import SwiftUI

struct EditInterestPopupModal: View {
    @State private var selectedInterests: Set<String> = []
    @State private var isLoading = true
    @State private var isSaving = false
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var interestVM: InterestViewModel
    var onDismiss: () -> Void
    
    let maxInterests = 10
    let interestCategories: [String: [String]] = [
        "Learning & Growth": ["Reading", "Languages", "Coding", "Online Courses", "Writing"],
        "Health & Wellness": ["Fitness", "Yoga", "Meditation", "Nutrition", "Sleep"],
        "Daily Life": ["Cooking", "Cleaning", "Budgeting", "Shopping", "Home Repair"],
        "Creativity & Hobbies": ["Drawing", "Music", "Photography", "Gardening", "DIY Projects"],
        "Social & Community": ["Volunteering", "Parenting", "Pet Care", "Travel Planning"]
    ]
    
    var isUpdateDisabled: Bool {
        selectedInterests.isEmpty
    }
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Edit Your Interests")
                                .font(.system(size: 20, weight: .bold))
                            Text("Update your interests anytime")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray.opacity(0.6))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                
                // Divider
                Divider()
                
                // Selected Count Info
                if selectedInterests.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 32))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Select at least one interest")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                        
                        Text("\(selectedInterests.count) interest\(selectedInterests.count == 1 ? "" : "s") selected")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.green)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
                
                // Interest List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(interestCategories.keys).sorted(), id: \.self) { category in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(category)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                FlowLayout(spacing: 10) {
                                    ForEach(interestCategories[category] ?? [], id: \.self) { interest in
                                        EditInterestChip(
                                            interest: interest,
                                            isSelected: selectedInterests.contains(interest)
                                        ) {
                                            toggleInterest(interest)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(10)
                        }
                    }
                    .padding(16)
                }
                .frame(maxHeight: 350)
                
                // Update Button
                VStack(spacing: 10) {
                    Button(action: updateInterests) {
                        if isSaving {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .tint(.white)
                                Text("Updating...")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        } else {
                            Text("Update Interests")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(isUpdateDisabled ? Color.gray.opacity(0.3) : Color.appPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isUpdateDisabled || isSaving)
                    
                    Button(action: onDismiss) {
                        Text("Cancel")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .padding(16)
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(20)
        }
        .onAppear {
            loadUserInterests()
        }
    }
    
    private func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }
    
    private func loadUserInterests() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let userId = authVM.user?.uid {
                let saved = interestVM.getInterestsArray(userId: userId)
                selectedInterests = Set(saved)
            }
            isLoading = false
        }
    }
    
    private func updateInterests() {
        guard let userId = authVM.user?.uid else { return }
        
        isSaving = true
        
        let interestsArray = Array(selectedInterests)
        interestVM.saveUserInterests(interestsArray, userId: userId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSaving = false
            onDismiss()
        }
    }
}

// MARK: - EditInterestChip (for Profile Edit)
struct EditInterestChip: View {
    let interest: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .appPrimary : .gray.opacity(0.5))
                
                Text(interest)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.appPrimary.opacity(0.1) : Color.white)
            .border(
                isSelected ? Color.appPrimary : Color.gray.opacity(0.2),
                width: isSelected ? 1.5 : 0.5
            )
            .cornerRadius(8)
        }
    }
}
