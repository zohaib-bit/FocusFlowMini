//
//  AppRootView.swift
//  FlowFocusMini
//
//  Created by o9tech on 25/11/2025.
//

<<<<<<< HEAD

import SwiftUI
import SwiftData
=======
import SwiftUI
>>>>>>> main

struct AppRootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var flowVM = AppFlowViewModel()
<<<<<<< HEAD
    @Environment(\.modelContext) private var modelContext
    @State private var interestVM: InterestViewModel?
=======
>>>>>>> main

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
<<<<<<< HEAD
=======
                // User not logged in - show SignIn
>>>>>>> main
                SignIn()
                    .environmentObject(authVM)
            }
            else {
                // User is logged in - show main app
<<<<<<< HEAD
                if let interestVM = interestVM {
                    RootView()
                        .environmentObject(authVM)
                        .environmentObject(interestVM)
                }
            }
        }
        .onAppear {
            // Initialize InterestViewModel
            if interestVM == nil {
                interestVM = InterestViewModel(modelContext: modelContext)
=======
                RootView()
                    .environmentObject(authVM)
>>>>>>> main
            }
        }
    }
}
