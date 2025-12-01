
//
//  Client Interest.swift
//  FlowFocusMini
//
//  Created by o9tech on 26/11/2025.
//

import SwiftUI

struct Client_Interest: View {
    @State private var selectedInterests: Set<String> = []
    
    let maxInterests = 20
    let interestCategories: [String: [String]] = [
        " Learning & Growth": ["Reading", "Languages", "Coding", "Online Courses", "Writing"],
        " Health & Wellness": ["Fitness", "Yoga", "Meditation", "Nutrition", "Sleep"],
        " Daily Life": ["Cooking", "Cleaning", "Budgeting", "Shopping", "Home Repair"],
        " Creativity & Hobbies": ["Drawing", "Music", "Photography", "Gardening", "DIY Projects"],
        " Social & Community": ["Volunteering", "Parenting", "Pet Care", "Travel Planning"]
    ]
    
    var isNextDisabled: Bool {
        selectedInterests.isEmpty
    }
    
    var body: some View {
        ZStack {
            // Background
            Background()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose things you're really into")
                        .font(.system(size: 24, weight: .bold))
                    Text("Pick your interests to personalize your tasks and suggestions.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                .padding(20)
                .padding(.top, 90)
                
                // Selection Counter
                HStack {
                    Text("\(selectedInterests.count) of \(maxInterests) selected")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                // Interest List
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(interestCategories.keys).sorted(), id: \.self) { category in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(category)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.gray)
                                
                                FlowLayout(spacing: 10) {
                                    ForEach(interestCategories[category] ?? [], id: \.self) { interest in
                                        InterestChip(
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
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(20)
                }
                
                Spacer()
                
                // Footer Buttons
                VStack(spacing: 12) {
                    Button(action: {}) {
                        Text("Next")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(isNextDisabled ? Color.gray.opacity(0.3) : Color.appPrimary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isNextDisabled)
                }
                .padding(20)
            }
        }
    }
    
    private func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else if selectedInterests.count < maxInterests {
            selectedInterests.insert(interest)
        }
    }
}

struct InterestChip: View {
    let interest: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(interest)
                    .font(.system(size: 14, weight: .medium))
            }
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

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var height: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        let availableWidth = proposal.width ?? 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if currentRowWidth + spacing + size.width > availableWidth {
                height += size.height + spacing
                currentRowWidth = size.width
            } else {
                currentRowWidth += (currentRowWidth > 0 ? spacing : 0) + size.width
            }
        }
        height += subviews.first?.sizeThatFits(.unspecified).height ?? 0
        return CGSize(width: availableWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += size.height + spacing
            }
            view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
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

#Preview {
    Client_Interest()
}
