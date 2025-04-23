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
        VStack(spacing: 16) {
            Text("Create a New Account").font(.largeTitle)

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text(errorMessage)
                .foregroundColor(.red)
                .font(.footnote)

            Button("Create Account") {
                createAccount()
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
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
