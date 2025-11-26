import SwiftUI

struct SplashScreen: View {
    @EnvironmentObject var flowVM: AppFlowViewModel

    @State private var logoScale: CGFloat = 0.6
    
    var body: some View {
        ZStack {
            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .scaleEffect(logoScale)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        logoScale = 1.0
                    }
                    // Call the method from AppFlowViewModel
                    flowVM.showSplashScreen()
                }
        }
    }
}
