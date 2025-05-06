//
//  SessionStore.swift
//  Easy Money
//
//  Created by Luka Surguladze on 5/6/25.
//

import Foundation
import FirebaseAuth
import Combine

/// Observes FirebaseAuth and publishes a single `isLoggedIn` Bool.
class SessionStore: ObservableObject {
  @Published var isLoggedIn = false
  private var handle: AuthStateDidChangeListenerHandle?

  init() {
    // Start listening as soon as this object is created
    handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
      self?.isLoggedIn = (user != nil)
    }
  }

  deinit {
    // Clean up the listener when this object is deallocated
    if let h = handle {
      Auth.auth().removeStateDidChangeListener(h)
    }
  }
}
