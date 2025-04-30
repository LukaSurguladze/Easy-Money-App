//
//  HomePage.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI

struct spentButton: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Chewy-Regular", size: 25))
            .frame(maxWidth: 150, minHeight: 150)
            .background(Image("SPbackground").resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all))
            .foregroundColor(.black)
            .cornerRadius(25)
            .opacity(1)
            .shadow(radius: 3, y: 2)
    }
}
struct madeButton: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Chewy-Regular", size: 25))
            .frame(maxWidth: 150, minHeight: 150)
            .background(Image("MPbackground").resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all))
            .foregroundColor(.black)
            .cornerRadius(25)
            .opacity(1)
            .shadow(radius: 3, y: 2)
    }
}
struct reportButton: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Chewy-Regular", size: 25))
            .frame(maxWidth: 150, minHeight: 150)
            .background(Image("RPbackground").resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all))
            .foregroundColor(.black)
            .cornerRadius(25)
            .opacity(1)
            .shadow(radius: 3, y: 2)
    }
}
struct catButton: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Chewy-Regular", size: 25))
            .frame(maxWidth: 150, minHeight: 150)
            .background(Image("CPbackground").resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all))
            .foregroundColor(.black)
            .cornerRadius(25)
            .opacity(1)
            .shadow(radius: 3, y: 2)
    }
}
struct logoutButton: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Chewy-Regular", size: 25))
    }
}

struct HomePage: View {
    @Binding var isLoggedIn: Bool
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            
            GeometryReader { geo in
                ZStack {
                    // 1) Your fullscreen background
                    Image("HPbackground")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: geo.size.width,
                               height: geo.size.height)
                    
                    VStack(spacing: 24) {
                        Text("Pocket Insight")
                            .font(.custom("Chewy-Regular", size: 50))
                            .foregroundColor(.black)
                            .padding()
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                                NavigationLink("Spent", destination: SpendPage())
                                .buttonStyle(spentButton(color: .red))
                                
                                NavigationLink("Earned", destination: MadePage())
                                    .buttonStyle(madeButton(color: .green))
                                
                                NavigationLink("Report", destination: ReportPage())
                                    .buttonStyle(reportButton(color: .purple))
                                
                                NavigationLink("Categories", destination: PersonPage())
                                    .buttonStyle(catButton(color: .orange))
                            }
                        Spacer()
                        
                        Button("Logout") {
                            logout()
                        }
                        .buttonStyle(logoutButton(color: .red))
                    }
               
            
            .padding()
            .navigationBarHidden(true)
        }
        }
        }
    }

    private func logout() {
        // Keep the account; only end session:
        UserDefaults.standard.removeObject(forKey: "currentUser")
        isLoggedIn = false
    }
}
