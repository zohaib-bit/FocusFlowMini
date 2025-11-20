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
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // MARK: - Background
                    Image("bg_onboarding")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .ignoresSafeArea()
                    
                    VStack {
                        
                        // MARK: - Logo (Top)
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.width * 0.1) // auto shrink on SE
                            .padding(.top, geo.size.height * 0.02)
                        
                        Spacer(minLength: geo.size.height * 0.05)
                        
                        // MARK: - Center Image + Text
                        VStack(spacing: geo.size.height * 0.02) {
                            
                            Image(viewModel.onboardingItems[viewModel.currentIndex].image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: geo.size.height * 0.30)  // adjusts for SE
                        
                            VStack(spacing: geo.size.height * 0.015) {
                                Text(viewModel.onboardingItems[viewModel.currentIndex].title)
                                    .font(.system(
                                        size: geo.size.height * 0.035,  // title scales
                                        weight: .bold
                                    ))
                                    .multilineTextAlignment(.center)
                                
                                Text(viewModel.onboardingItems[viewModel.currentIndex].description)
                                    .font(.system(size: geo.size.height * 0.018)) // description scales
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer(minLength: geo.size.height * 0.06)
                        
                        // MARK: - Bottom Button
                        Button(action: { viewModel.next() }) {
                            Text(viewModel.isLastItem ? "Get Started" : "Next")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.appPrimary)
                                .cornerRadius(16)

                        }
                        .padding(.horizontal, geo.size.width * 0.15)
                        .padding(.bottom, geo.size.height * 0.04)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToHome) {
                RootView()
            }
        }
    }
}


//extension Color {
//    
//    init(hex: String) {
//        // Remove all non-hex characters (#, spaces, etc.)
//        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        
//        var int: UInt64 = 0
//        Scanner(string: cleaned).scanHexInt64(&int)
//        
//        let a, r, g, b: UInt64
//        
//        switch cleaned.count {
//        case 3: // RGB (12-bit) e.g. #0A3
//            a = 255
//            r = (int >> 8) * 17
//            g = (int >> 4 & 0xF) * 17
//            b = (int & 0xF) * 17
//            
//        case 6: // RGB (24-bit) e.g. #028080
//            a = 255
//            r = int >> 16
//            g = int >> 8 & 0xFF
//            b = int & 0xFF
//            
//        case 8: // ARGB (32-bit) e.g. FF028080
//            a = int >> 24
//            r = int >> 16 & 0xFF
//            g = int >> 8 & 0xFF
//            b = int & 0xFF
//            
//        default:
//            // Fallback: Gray for invalid hex
//            a = 255; r = 128; g = 128; b = 128
//        }
//        
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//    
//    // Unlabeled shorthand usage: Color("028080")
//    init(_ hex: String) {
//        self.init(hex: hex)
//    }
//}


#Preview {
    Onboardings()
}

