//
//  ContentView.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn: Bool = false

    var body: some View {
        Group {
            if isLoggedIn {
                HomePage(isLoggedIn: $isLoggedIn)
            } else {
                LoginPage(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            // Auto-login if credentials still exist
            if let _ = UserDefaults.standard.dictionary(forKey: "userCredentials") {
                isLoggedIn = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
