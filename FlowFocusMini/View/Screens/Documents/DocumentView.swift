//
//  DocumentView.swift
//  FlowFocusMini
//
//  Created by o9tech on 01/01/2026.
//

import SwiftUI

struct DocumentView: View {
    
    var body: some View {
        ZStack {
            Background()
                .ignoresSafeArea()
            
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        Header()
                            .padding(.horizontal, 20)
                        
                    }
                }
                .padding(.top, 110)
            }
        }
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
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            HStack(spacing: 0) {
                
                // Back Arrow
                HStack {
                    Image("ic_arrow")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 28, height: 12)
                }
                .frame(width: totalWidth * 0.33, alignment: .leading)
                
                // Title
                HStack {
                    Text("Document")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(width: totalWidth * 0.33, alignment: .center)
                
                // Bell Icon
                Button(action: {}) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                        
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
