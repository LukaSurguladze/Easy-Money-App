//
//  SignupPage.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI
import FirebaseAuth

struct SignupPage: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
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
                    
                    TextField("Username", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(25)
                        .shadow(radius: 2, y: 1)
                    TextField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(25)
                        .shadow(radius: 2, y: 1)
                    TextField("Confirm Password", text: $confirmPassword)
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
    
    /// Uses FirebaseAuth to create a new user
       private func createAccount() {
           // 1) Basic validation
           guard !email.isEmpty else {
               errorMessage = "Email cannot be empty."
               return
           }
           guard password == confirmPassword, !password.isEmpty else {
               errorMessage = "Passwords must match and not be empty."
               return
           }

           // 2) Firebase create user call
           Auth.auth().createUser(withEmail: email, password: password) { result, error in
               if let error = error {
                   // Show Firebase’s error message
                   errorMessage = error.localizedDescription
               } else {
                   // Success: user is automatically logged in
                   isLoggedIn = true
               }
           }
       }
   }
