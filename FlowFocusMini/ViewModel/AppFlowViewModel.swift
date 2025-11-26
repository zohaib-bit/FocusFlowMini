//
//  AppFlowViewModel.swift
//  FlowFocusMini
//
//  Created by o9tech on 25/11/2025.
//

import SwiftUI

class AppFlowViewModel: ObservableObject {

    @Published var showSplash: Bool = true
    @Published var showOnboarding: Bool = false

    init() {
        showSplashScreen()
    }

    func showSplashScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showSplash = false
            self.showOnboarding = !UserDefaults.standard.bool(forKey: "hasOnboarded")
        }
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasOnboarded")
        showOnboarding = false
    }
}
