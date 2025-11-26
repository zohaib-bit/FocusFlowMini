import SwiftUI

struct Onboardings: View {

    // MARK: - ADD THIS
    let finish: () -> Void

    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    
                    Image("bg_onboarding")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .ignoresSafeArea()

                    VStack {

                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.width * 0.1)
                            .padding(.top, geo.size.height * 0.02)

                        Spacer(minLength: geo.size.height * 0.05)

                        VStack(spacing: geo.size.height * 0.02) {

                            Image(viewModel.onboardingItems[viewModel.currentIndex].image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: geo.size.height * 0.30)

                            VStack(spacing: geo.size.height * 0.015) {
                                Text(viewModel.onboardingItems[viewModel.currentIndex].title)
                                    .font(.system(
                                        size: geo.size.height * 0.035,
                                        weight: .bold
                                    ))
                                    .multilineTextAlignment(.center)

                                Text(viewModel.onboardingItems[viewModel.currentIndex].description)
                                    .font(.system(size: geo.size.height * 0.018))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        }

                        Spacer(minLength: geo.size.height * 0.06)

                        Button(action: {
                            if viewModel.isLastItem {
                                finish()        // ← CALLS THE CLOSURE
                            } else {
                                viewModel.next()
                            }
                        }) {
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
                }
            }
        }
    }
}

#Preview {
    Onboardings(finish: {})
}
