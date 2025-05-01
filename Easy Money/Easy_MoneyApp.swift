//
//  Easy_MoneyApp.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

// ② Define an AppDelegate to call FirebaseApp.configure()
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct Easy_MoneyApp: App {
  // ③ Register the delegate
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear {
          // ④ Enable Firestore offline persistence
            // grab the existing settings
            let settings = Firestore.firestore().settings

            // explicitly use the persistent (on-disk) cache
            settings.cacheSettings = PersistentCacheSettings()

            // commit them back
            Firestore.firestore().settings = settings
        }
    }
  }
}
