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

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions
      launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    // 1. Initialize the core Firebase SDK
    FirebaseApp.configure()

    // 2. Enable Crashlytics collection
    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)

    // 3. Log a first “app_open” event for Analytics
    Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)

    // 4. Turn on Firestore’s on-disk cache
      let settings = Firestore.firestore().settings
    settings.cacheSettings = PersistentCacheSettings()
    Firestore.firestore().settings = settings

    return true
  }
}

@main
struct Easy_MoneyApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
