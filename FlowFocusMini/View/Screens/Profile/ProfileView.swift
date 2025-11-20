//
//  ProfileView.swift
//  FlowFocusMini
//
//  Created by o9tech on 14/11/2025.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        
        ZStack {
            Background()
                .ignoresSafeArea()
            
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        
                        Header()
                            .padding(.horizontal, 20)
                        
                        ProfileImage()
                            .padding(.horizontal, 20)

                        EditBtn {
                            print("Edit tapped")
                        }
                        .padding(.horizontal, 20)
                        
                        ProfileMenuList()
                            .padding(.bottom, 120)  // for bottom nav



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
                    Text("Profile")
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

private struct ProfileImage: View {
    var body: some View {
        VStack(spacing: 16) {
            
            Image("img_profile")
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .clipShape(Circle())
            
            Text("Username")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.primary)

            Text("Email")
                .font(.system(size: 20))
                .foregroundColor(.black)
                .padding(.top, 5)
        }
        .padding(.vertical, 20)
    }
}

private struct EditBtn: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Edit")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7) // 70% Width
                .background(Color.appPrimary)
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
    }
}


private struct ProfileMenuList: View {
    var body: some View {
        VStack(spacing: 0) {
            
            NavigationRow(icon: "gearshape", title: "Setting") {
                print("Go to settings")
            }
            
            NavigationRow(icon: "person.2", title: "Friend") {
                print("Go to friends")
            }
            

            
            NavigationRow(icon: "questionmark.bubble", title: "Support") {
                print("Go to support")
            }
            
            NavigationRow(icon: "square.and.arrow.up", title: "Share") {
                print("Share tapped")
            }
            
            NavigationRow(icon: "questionmark.circle", title: "About Us") {
                print("Go to about us")
            }
            
        }
        .cornerRadius(16)
    }
}

private struct NavigationRow: View {
    var icon: String
    var title: String
    var action: () -> Void
    
    var body: some View {
        
        Button(action: action) {
            HStack(spacing: 16) {
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color.appPrimary.opacity(0.8))
                
                Text(title)
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                Color.appPrimary.opacity(0.08) // soft purple shade
                    .cornerRadius(12)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }
}


#Preview {
    ProfileView()
}
