//
//  AppRootView.swift
//  FlowFocusMini
//
//  Created by o9tech on 25/11/2025.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var flowVM = AppFlowViewModel()

    var body: some View {
        Group {
            if flowVM.showSplash {
                SplashScreen()
                    .environmentObject(flowVM)
            }
            else if flowVM.showOnboarding {
                Onboardings {
                    flowVM.completeOnboarding()
                }
            }
            else if authVM.user == nil {
                // User not logged in - show SignIn
                SignIn()
                    .environmentObject(authVM)
            }
            else {
                // User is logged in - show main app
                RootView()
                    .environmentObject(authVM)
            }
        }
    }
}
