//
//  Easy_MoneyApp.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseCrashlytics
import FirebaseAnalytics

// Your existing AppDelegate stays the same
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions
      launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
    Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)

    let settings = Firestore.firestore().settings
    settings.cacheSettings = PersistentCacheSettings()
    Firestore.firestore().settings = settings

    return true
  }
}

@main
struct Easy_MoneyApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  // 1️⃣ Add the session store here
  @StateObject private var session = SessionStore()

  var body: some Scene {
    WindowGroup {
      // 2️⃣ Inject it into the environment
      ContentView()
        .environmentObject(session)
    }
  }
}
