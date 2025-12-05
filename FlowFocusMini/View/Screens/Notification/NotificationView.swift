//
//  NotificationView.swift
//  FlowFocusMini
//
//  Created by o9tech on 05/12/2025.
//

import SwiftUI

struct NotificationView: View {
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Background()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Header(dismiss: dismiss)
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                
                
                ScrollView(showsIndicators: false) {
                    VStack() {
                        
                    }
                }
            }
            .padding(.top, 50)

        }
        .navigationBarHidden(true)

    }
}



private struct Background: View {
    var body: some View {
        Image("bg_home")
            .resizable()
            .scaledToFill()
    }
}

private struct Header: View {
    let dismiss: DismissAction
    
    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image("ic_arrow")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 12)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Notifications")
                    .font(.system(size: 22, weight: .bold))
                
             
            }
            
            Spacer()
            
            Circle()
                .fill(Color.clear)
                .frame(width: 40, height: 40)
        }
    }
}

#Preview {
    NotificationView()
}
