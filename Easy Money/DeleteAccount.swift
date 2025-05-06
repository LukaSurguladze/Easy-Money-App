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
  @EnvironmentObject private var session: SessionStore
  @Environment(\.presentationMode) private var presentationMode

  @State private var isDeleting = false
  @State private var alertItem: AlertItem?

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
                    .background(
                        Image("PIBackground")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                    )
                    .navigationBarBackButtonHidden(isDeleting)
                    .alert(item: $alertItem) { $0.alert }
                }
            }
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

    let db      = Firestore.firestore()
    let userRef = db.collection("users").document(user.uid)

    // — your subcollections —
    let subCollections = ["spends","earns","categories","settings"]

    do {
      // 1) delete all docs in each subcollection
      for col in subCollections {
        let snap = try await userRef.collection(col).getDocuments()
        for doc in snap.documents {
          try await doc.reference.delete()
        }
      }

      // 2) delete the user document itself
      try await userRef.delete()

      // 3) delete the Auth user
      try await user.delete()

      // 4) sign out — triggers SessionStore to flip back to LoginPage
      try Auth.auth().signOut()

      // 5) (optional) dismiss this view
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


/// Helper so we can drive `.alert(item:)`
private struct AlertItem: Identifiable {
  let id = UUID()
  let alert: Alert

  init(
    title: Text,
    message: Text? = nil,
    primaryButton: Alert.Button? = nil,
    secondaryButton: Alert.Button? = nil,
    dismissButton: Alert.Button? = nil
  ) {
    if let p = primaryButton, let s = secondaryButton {
      alert = Alert(title: title, message: message, primaryButton: p, secondaryButton: s)
    } else if let d = dismissButton {
      alert = Alert(title: title, message: message, dismissButton: d)
    } else {
      alert = Alert(title: title, message: message)
    }
  }
}
