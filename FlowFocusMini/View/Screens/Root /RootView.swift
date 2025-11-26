import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TaskViewModel(apiKey: Config.openaiAPIKey)
    
    @State private var selectedTab = 0
    @State private var showAddTask = false

    var body: some View {
        ZStack {
            // MARK: - Main Tab Bar
            TabView(selection: $selectedTab) {
                
                HomeView()
                    .tag(0)
                    .tabItem {
                        Image(systemName: "house.fill")
                            .frame(width: 24, height: 24)
                    }

                CalenderView()
                    .tag(2)
                    .tabItem {
                        Image(systemName: "calendar")
                        .frame(width: 24, height: 24)

                    }
                

                DocumentView()
                    .tag(1)
                    .tabItem {
                        Image(systemName: "doc.fill")
                        .frame(width: 24, height: 24)

                    }

                ProfileView()
                    .tag(3)
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        .frame(width: 24, height: 24)

                    }
            }
            .accentColor(.appPrimary)

            // MARK: - Floating Add Button
            VStack {
                Spacer()
                Button(action: {
                    showAddTask = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .padding(18)
                        .background(Color.appPrimary)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .offset(y: -20)  // lift above tab bar
            }
        }
        .environmentObject(viewModel)  // ← CRITICAL: This injects ViewModel
        .sheet(isPresented: $showAddTask) {
            Client_Interest()
                .environmentObject(viewModel)  // ← CRITICAL: Re-inject for sheet
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: TodoTask.self)
}
