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
        GeometryReader { geo in
          ZStack {
            // 1) Your fullscreen background
            Image("AppBackground")
              .resizable()
              .scaledToFill()
              .edgesIgnoringSafeArea(.all)
              .frame(width: geo.size.width,
                     height: geo.size.height)

            // 2) Your existing form stays in place
            VStack(spacing: 24) {
              Text("Welcome Back!")
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

              Button("Login") {
                loginUser()
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

              // Note: NO Spacer here!
              // NavigationLink was here before but we moved it out
            }
            .padding()
            .navigationBarHidden(true)

            // 3) A second VStack that lives on top, pinned to the bottom:
            VStack {
              Spacer()   // push the link down
              NavigationLink("Create New Account",
                             destination: SignupPage(isLoggedIn: $isLoggedIn))
                .font(.custom("Chewy-Regular", size: 20))
                .foregroundColor(.white)
                .padding(.bottom, 30)   // breathe room under the home-indicator
            }
            // Ensure it spans the full area so the Spacer() works:
            .frame(width: geo.size.width, height: geo.size.height)
          }
        }
        .navigationViewStyle(.stack)
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
