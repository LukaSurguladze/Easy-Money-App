//
//  LoginPage.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI

struct LoginPage: View {
    @Binding var isLoggedIn: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
            NavigationView {
                GeometryReader{ geo in
                    ZStack {
                        Image("AppBackground")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                            .frame(width:  geo.size.width, height: geo.size.height,
                                   alignment: .center)
                        
                        
                        VStack(spacing: 16) {
                            Text("Login").font(.largeTitle)
                            
                            TextField("Username", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            SecureField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                            
                            Button("Login") {
                                loginUser()
                            }
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            
                            NavigationLink("Create New Account", destination: SignupPage(isLoggedIn: $isLoggedIn))
                                .padding(.top, 8)
                        }
                        .padding()
                        .navigationBarHidden(true)
                    }
                }
            }
        }
    private func loginUser() {
        // Fetch the global user→password map
        let allCreds = UserDefaults.standard.dictionary(forKey: "allUserCredentials") as? [String:String] ?? [:]

        guard let storedPass = allCreds[username] else {
            errorMessage = "No account named ‘\(username)’ found."
            return
        }

        if password == storedPass {
            // success: mark session
            UserDefaults.standard.set(username, forKey: "currentUser")
            errorMessage = ""
            isLoggedIn = true
        } else {
            errorMessage = "Invalid password for \(username)."
        }
    }
}
