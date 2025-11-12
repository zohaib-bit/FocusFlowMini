//
//  Onboardings.swift
//  FlowFocusMini
//
//  Created by o9tech on 12/11/2025.
//

import SwiftUI

import SwiftUI

struct Onboardings: View {
 
    @StateObject private var viewModel = OnboardingViewModel()
        
        var body: some View {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // MARK: - Logo Section
                    Image("logo") // Replace with your logo asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.3)
                        .padding(.top, 40)
                        .accessibilityLabel("App Logo")
                    
                    Spacer()
                    
                    // MARK: - Illustration Section
                    Image(viewModel.onboardingItems[viewModel.currentIndex].image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7,
                               maxHeight: UIScreen.main.bounds.height * 0.3)
                        .transition(.scale.combined(with: .opacity))
                        .id(viewModel.onboardingItems[viewModel.currentIndex].image)
                    
                    // MARK: - Text Section
                    VStack(spacing: 16) {
                        Text(viewModel.onboardingItems[viewModel.currentIndex].title)
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        Text(viewModel.onboardingItems[viewModel.currentIndex].description)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                    }
                    .padding(.horizontal)
                    .animation(.easeInOut, value: viewModel.currentIndex)
                    
                    Spacer()
                    
                    // MARK: - Button Section
                    Button(action: { viewModel.next() }) {
                        Text(viewModel.isLastItem ? "Get Started" : "Next")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("008080"))
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    }
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.15)
                    .padding(.bottom, 40)
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
}


extension Color {
    // Your existing labeled initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // Unlabeled convenience initializer that forwards to init(hex:)
    init(_ hex: String) {
        self.init(hex: hex)
    }
}

#Preview {
    Onboardings()
}

