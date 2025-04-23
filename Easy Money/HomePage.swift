//
//  HomePage.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI

struct FilledButton: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct HomePage: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to the Home Page!")
                    .font(.title)
                    .padding()

                NavigationLink("Go to Spend Page", destination: SpendPage())
                    .buttonStyle(FilledButton(color: .blue))

                NavigationLink("Go to Made Page", destination: MadePage())
                    .buttonStyle(FilledButton(color: .green))

                NavigationLink("View Report", destination: ReportPage())
                    .buttonStyle(FilledButton(color: .purple))

                NavigationLink("View Categories", destination: PersonPage())
                    .buttonStyle(FilledButton(color: .orange))

                Spacer()

                Button("Logout") {
                    logout()
                }
                .buttonStyle(FilledButton(color: .red))
            }
            .padding()
            .navigationBarHidden(true)
        }
    }

    private func logout() {
        // Keep the account; only end session:
        UserDefaults.standard.removeObject(forKey: "currentUser")
        isLoggedIn = false
    }
}
