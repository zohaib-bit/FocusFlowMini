import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TaskViewModel(apiKey: Config.openaiAPIKey)
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var notificationVM: NotificationViewModel
    @EnvironmentObject private var interestVM: InterestViewModel
    
    
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
                .offset(y: -20)
            }
            
            // MARK: - Toast Notification Overlay
            if notificationVM.showToast, let notification = notificationVM.toastNotification {
                VStack {
                    ToastNotificationView(
                        notification: notification,
                        onDismiss: {
                            notificationVM.dismissToast()
                        }
                    )
                    
                    Spacer()
                }
                .padding(.top, 60)
                .zIndex(1000)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .environmentObject(viewModel)
        .sheet(isPresented: $showAddTask) {
            AddTaskView()
                .environmentObject(viewModel)
                .environmentObject(notificationVM)
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
            notificationVM.setModelContext(modelContext)
            
        }
    }
}
