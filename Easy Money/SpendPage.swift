//
//  SpendPage.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SpendPage: View {
    // 1) Who’s logged in?
    private let db = Firestore.firestore()
    private var uid: String? { Auth.auth().currentUser?.uid }
    // 2) Dynamic, per-user categories
    @State private var categories: [String] = []
    @State private var amount = ""
    @State private var selectedCategory = ""
    @State private var selectedDate = Date()
    @State private var errorMessage = ""
    @State private var showConfirmation = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader{ geo in
            ZStack {
                Image("SPbackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(width: geo.size.width,
                           height: geo.size.height)
                
                VStack(spacing: 16) {
                    Text("Amount Spent").font(.custom("Chewy-Regular", size: 50))
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.custom("Chewy-Regular", size: 20))
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(25)
                        .shadow(radius: 2, y: 1)
                        .frame(maxWidth: .infinity, minHeight: 50)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 120)
                    .clipped()
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .font(.custom("Chewy-Regular", size: 20))
                    Text(errorMessage).foregroundColor(.red).font(.footnote)
                    
                    Spacer()
                    
                    Button("Enter") { saveAmount() }
                        .font(.custom("Chewy-Regular", size: 20))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.red.opacity(0.75))
                        .foregroundColor(.black)
                        .cornerRadius(25)
                        .shadow(radius: 2, y: 1)
                    
                }
                .padding()
                .onAppear {
                    loadCategories()
                }
                .alert("Success", isPresented: $showConfirmation) {
                    Button("OK", action: dismiss.callAsFunction)
                } message: {
                    Text("Your amount spent has been recorded.")
                }
            }
        }
    }
    
    /// Fetches categories from Firestore (or defaults if empty)
        private func loadCategories() {
            guard let uid = uid else { return }
            db.collection("users")
              .document(uid)
              .collection("categories")
              .getDocuments { snapshot, error in
                  if let error = error {
                      print("Error loading categories: \(error)")
                      categories = ["Food", "Bills", "Activities"]
                  } else {
                      let docs = snapshot?.documents ?? []
                      let names = docs.compactMap { $0.data()["name"] as? String }
                      categories = names.isEmpty ? ["Food", "Bills", "Activities"] : names
                  }
                  if selectedCategory.isEmpty {
                      selectedCategory = categories.first ?? ""
                  }
              }
        }

        /// Saves a spend entry into Firestore under current user's "spends"
        private func saveAmount() {
            guard let uid = uid else {
                errorMessage = "User not logged in."
                return
            }
            guard let value = Double(amount), value > 0 else {
                errorMessage = "Please enter a valid amount."
                return
            }

            let data: [String: Any] = [
                "amount": value,
                "category": selectedCategory,
                "date": Timestamp(date: selectedDate)
            ]

            db.collection("users")
              .document(uid)
              .collection("spends")
              .addDocument(data: data) { error in
                  if let error = error {
                      errorMessage = error.localizedDescription
                  } else {
                      amount = ""
                      errorMessage = ""
                      showConfirmation = true
                  }
              }
        }
    }

    struct SpendPage_Previews: PreviewProvider {
        static var previews: some View {
            SpendPage()
        }
    }
