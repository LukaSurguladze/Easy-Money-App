//
//  DeleteAccount.swift
//  Easy Money
//
//  Created by Luka Surguladze on 5/6/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct DeleteAccount: View {
  @Environment(\.presentationMode) private var presentationMode

  @State private var isDeleting = false
  @State private var alertItem: AlertItem?

  var body: some View {
    NavigationView {
      ZStack {
        Image("PIBackground")
          .resizable()
          .scaledToFill()
          .ignoresSafeArea()

        VStack(spacing: 32) {
          Spacer(minLength: 40)

          Text("Delete Account")
            .font(.custom("Chewy-Regular", size: 36))
            .foregroundColor(.black)

          Text("""
            Deleting your account will permanently remove **all** of your data \
            (categories, earnings, spending, settings). This action **cannot be undone**.
            """)
            .multilineTextAlignment(.center)
            .font(.custom("Chewy-Regular", size: 18))
            .foregroundColor(.black)
            .padding(.horizontal, 32)

          if isDeleting {
            ProgressView("Deleting…")
              .progressViewStyle(.circular)
          } else {
            Button("Delete My Account") {
              showConfirmation()
            }
            .font(.custom("Chewy-Regular", size: 20))
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 32)
            .background(Color.red)
            .cornerRadius(12)
          }

          Spacer()
        }
        .padding()
      }
      .navigationBarBackButtonHidden(isDeleting)
      .alert(item: $alertItem) { $0.alert }
    }
  }

  private func showConfirmation() {
    alertItem = .init(
      title: Text("Are you sure?"),
      message: Text("This will permanently remove your account and **all data**."),
      primaryButton: .destructive(Text("Delete")) {
        Task { await performFullDeletion() }
      },
      secondaryButton: .cancel()
    )
  }

  @MainActor
  private func performFullDeletion() async {
    guard let user = Auth.auth().currentUser else { return }
    isDeleting = true

    let db     = Firestore.firestore()
    let userID = user.uid
    let userRef = db.collection("users").document(userID)

    // 1) Hard-coded list of your subcollections
    let subCollections = [
      "spends",      // <— rename to your exact path
      "earns",     // <— rename to your exact path
      "categories", // <— rename to your exact path
      "settings"    // <— rename if different / remove if none
    ]

    do {
      // delete each sub-collection’s docs
      for col in subCollections {
        let snapshot = try await userRef.collection(col).getDocuments()
        for doc in snapshot.documents {
          try await doc.reference.delete()
        }
      }

      // 2) delete the user document itself
      try await userRef.delete()

      // 3) delete the Auth account
      try await user.delete()

      // 4) sign out & pop back to login
      try Auth.auth().signOut()
      presentationMode.wrappedValue.dismiss()

    } catch {
      alertItem = .init(
        title: Text("Error"),
        message: Text(error.localizedDescription),
        dismissButton: .default(Text("OK"))
      )
    }

    isDeleting = false
  }
}


/// A little helper so we can drive `.alert(item:)` with dynamic buttons
private struct AlertItem: Identifiable {
  let id = UUID()
  let alert: Alert

  init(title: Text,
       message: Text? = nil,
       primaryButton: Alert.Button? = nil,
       secondaryButton: Alert.Button? = nil,
       dismissButton: Alert.Button? = nil)
  {
    if let p = primaryButton, let s = secondaryButton {
      alert = Alert(title: title, message: message, primaryButton: p, secondaryButton: s)
    } else if let d = dismissButton {
      alert = Alert(title: title, message: message, dismissButton: d)
    } else {
      alert = Alert(title: title, message: message)
    }
  }
}
