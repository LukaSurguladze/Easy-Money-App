//
//  SignupPage.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI

struct SignupPage: View {
    @Binding var isLoggedIn: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""

    var body: some View {
        GeometryReader{ geo in
            ZStack {
                // 1) Your fullscreen background
                Image("AppBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(width: geo.size.width,
                           height: geo.size.height)
                
                
                VStack(spacing: 24) {
                    Text("Welcome!")
                        .font(.custom("Chewy-Regular", size: 50))
                        .foregroundColor(.white)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(25)
                        .shadow(radius: 2, y: 1)
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(25)
                        .shadow(radius: 2, y: 1)
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(25)
                        .shadow(radius: 2, y: 1)
                    
                    Button("Create Account") {
                        createAccount()
                    }
                    .font(.custom("Chewy-Regular", size: 35))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color("ActionButton"))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .shadow(radius: 3, y: 2)
                    
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                
                .padding()
            }
        }
    }

    private func createAccount() {
        // Basic validation
        guard !username.isEmpty else {
            errorMessage = "Username cannot be empty."
            return
        }
        guard password == confirmPassword, !password.isEmpty else {
            errorMessage = "Passwords must match and not be empty."
            return
        }

        // Load existing user→password map
        var allCreds = UserDefaults.standard.dictionary(forKey: "allUserCredentials") as? [String:String] ?? [:]

        // Prevent duplicates
        guard allCreds[username] == nil else {
            errorMessage = "An account named ‘\(username)’ already exists."
            return
        }

        // Add new user
        allCreds[username] = password
        UserDefaults.standard.set(allCreds, forKey: "allUserCredentials")

        // Immediately mark session
        UserDefaults.standard.set(username, forKey: "currentUser")
        errorMessage = ""
        isLoggedIn = true
    }
}
