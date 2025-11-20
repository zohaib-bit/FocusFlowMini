//
//  OnboardingViewModel.swift
//  FlowFocusMini
//
//  Created by o9tech on 12/11/2025.
//

import SwiftUI

@MainActor

final class OnboardingViewModel: ObservableObject{
   
    @Published var currentIndex: Int = 0
    @Published var shouldNavigateToHome: Bool = false
    
    
    // Data Source
    let onboardingItems: [OnboardingItem] = [
        OnboardingItem(image: "onboarding_one",
                       title: "Stay Focused",
                       description: "Manage your time efficiently and stay focused on what truly matters."),
    
        OnboardingItem(image: "onboarding_two",
                       title: "Track Progress",
                       description: "See your daily achievements and track your journey toward success."),
        
        OnboardingItem(image: "onboarding_three",
                       title: "Achieve Goals",
                       description: "Set realistic goals and crush them one day at a time!")
    ]
    
    var isLastItem: Bool {
        currentIndex == onboardingItems.count - 1
    }
    
    func next() {
        if currentIndex < onboardingItems.count - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)){
                currentIndex += 1
            }
        } else{
        
            withAnimation {
                shouldNavigateToHome = true
            }
            
        }
    }
    
}
