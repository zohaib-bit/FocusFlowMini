//
//  InterestPopupModal.swift
//  FlowFocusMini
//
//  Created by o9tech on 04/12/2025.
//

import SwiftUI

struct InterestPopupModal: View {
    @State private var selectedInterests: Set<String> = []
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var interestVM: InterestViewModel
    var onDismiss: () -> Void
    
    let maxInterests = 20
    let interestCategories: [String: [String]] = [
        " Learning & Growth": ["Reading", "Languages", "Coding", "Online Courses", "Writing"],
        " Health & Wellness": ["Fitness", "Yoga", "Meditation", "Nutrition", "Sleep"],
        " Daily Life": ["Cooking", "Cleaning", "Budgeting", "Shopping", "Home Repair"],
        " Creativity & Hobbies": ["Drawing", "Music", "Photography", "Gardening", "DIY Projects"],
        " Social & Community": ["Volunteering", "Parenting", "Pet Care", "Travel Planning"]
    ]
    
    var isDoneDisabled: Bool {
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
                    Text("Add Your Interests")
                        .font(.system(size: 20, weight: .bold))
                    Text("Pick your interests to personalize your experience")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                
                // Divider
                Divider()
                
                // Selection Counter
                HStack {
                    Text("\(selectedInterests.count) of \(maxInterests) selected")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                // Interest List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(interestCategories.keys).sorted(), id: \.self) { category in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(interestCategories[category] ?? [], id: \.self) { interest in
                                        PopupInterestChip(
                                            interest: interest,
                                            isSelected: selectedInterests.contains(interest),
                                            isDisabled: !selectedInterests.contains(interest) && selectedInterests.count >= maxInterests
                                        ) {
                                            toggleInterest(interest)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(8)
                        }
                    }
                    .padding(16)
                }
                .frame(maxHeight: 300)
                
                // Done Button
                VStack(spacing: 10) {
                    Button(action: saveAndDismiss) {
                        if interestVM.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Done")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(isDoneDisabled ? Color.gray.opacity(0.3) : Color.appPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isDoneDisabled || interestVM.isLoading)
                    
                    Button(action: onDismiss) {
                        Text("Skip for Now")
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
    }
    
    private func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else if selectedInterests.count < maxInterests {
            selectedInterests.insert(interest)
        }
    }
    
    private func saveAndDismiss() {
        guard let userId = authVM.user?.uid else { return }
        
        let interestsArray = Array(selectedInterests)
        interestVM.saveUserInterests(interestsArray, userId: userId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onDismiss()
        }
    }
}

// MARK: - PopupInterestChip (Local version - doesn't conflict with Client_Interest)
struct PopupInterestChip: View {
    let interest: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(interest)
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.appPrimary : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(8)
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}
