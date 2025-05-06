//
//  ContentView.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI

struct ContentView: View {
    // 1) One source of truth for auth state
    @StateObject private var session = SessionStore()

    var body: some View {
        Group {
            if session.isLoggedIn {
                // 2) Pass the binding into your HomePage
                HomePage(isLoggedIn: $session.isLoggedIn)
            } else {
                // 3) Or into your LoginPage
                LoginPage(isLoggedIn: $session.isLoggedIn)
            }
        }
        // no more UserDefaults lookup!
        .environmentObject(session)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
