//
//  DocumentView.swift
//  FlowFocusMini
//
//  Created by o9tech on 14/11/2025.
//

import SwiftUI

struct DocumentView: View {
    var body: some View {
        NavigationStack{
            ZStack{
                Background()
                    .ignoresSafeArea()
                
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Header()
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top,110)
                }
                
            }
        }
    }

}

private struct Background: View {
        var body: some View{
            Image("bg_home")
                .resizable()
                .scaledToFill()
        }
}

private struct Header: View {
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            HStack(spacing: 0) {
                // "home" text at top left
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 12) {
                        // Profile Image
                        Image("ic_arrow")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 28, height: 12)
        
                    }
                }
                .frame(width: totalWidth * 0.33, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 12) {
                        
                        // Text Section
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Documents")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                    }
                }
                .frame(width: totalWidth * 0.33, alignment: .center)
                
                // Notification Icon
                NavigationLink(destination: NotificationView()) {
                               ZStack(alignment: .topTrailing) {
                                   Image(systemName: "bell")
                                       .font(.system(size: 22))
                                       .foregroundColor(.black)
                                   
                                   // Notification dot
                                   Circle()
                                       .fill(Color.appPrimary)
                                       .frame(width: 8, height: 8)
                                       .offset(x: 4, y: -4)
                               }
                           }
                .frame(width: totalWidth * 0.33, alignment: .trailing)
            }
        }
        .frame(height: 40)
        .padding(.top, 10)
        
    }
}


#Preview {
    DocumentView()
}
