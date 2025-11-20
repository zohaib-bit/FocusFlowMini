//
//  splash.swift
//  FlowFocusMini
//
//  Created by o9tech on 12/11/2025.
//

import SwiftUI

struct SplashScreen: View {
    
    // MARK: - Properties
    
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.6
    
    var body: some View{
        if isActive{
            // after 2 sec move to nect screen
            Onboardings()
        }
        else{
            ZStack{
                Image("bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // Logo with animation
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .scaleEffect(logoScale)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            logoScale = 1.0
                    }
                }
                    .onAppear(){
                        // Delay 2 seconds → move to next screen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isActive = true
                            }
                            
                  }
                        
                }
            }
        }
    }
}

#Preview{
    SplashScreen()
}
