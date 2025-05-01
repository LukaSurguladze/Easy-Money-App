//
//  PersonPage.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PersonPage: View {
    @State private var categories: [String] = []
    @State private var amounts: [String: Double] = [:]
    @State private var newGroupName = ""
    @State private var showAddAlert = false
    @State private var isEditing = false

    // Firestore & Auth
    private let db = Firestore.firestore()
    private var uid: String? { Auth.auth().currentUser?.uid }
    private let defaultCategories = ["Food", "Bills", "Activities"]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("CPbackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(width: geo.size.width, height: geo.size.height)

                VStack(spacing: 0) {
                    Text("Your Categories")
                        .font(.custom("Chewy-Regular", size: 50))
                        .foregroundColor(.black)
                        .padding(.top)

                    List {
                        ForEach(categories, id: \.self) { cat in
                            HStack {
                                Text(cat)
                                    .font(.custom("Chewy-Regular", size: 20))
                                Spacer()
                                Text("$\(amounts[cat] ?? 0, specifier: "%.2f")")
                                    .font(.custom("Chewy-Regular", size: 20))
                            }
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteCategories)
                    }
                    .listStyle(.insetGrouped)
                    .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive))
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)

                    Button("Add New Category") {
                        showAddAlert = true
                    }
                    .font(.custom("Chewy-Regular", size: 20))
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.pink.opacity(0.65))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(isEditing ? "Done" : "Edit") {
                            withAnimation { isEditing.toggle() }
                        }
                    }
                }
                .onAppear { loadCategories() }
                .alert("Add Category", isPresented: $showAddAlert) {
                    TextField("Category Name", text: $newGroupName)
                    Button("Add", action: addCategory)
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Enter a new category name.")
                }
            }
        }
    }

    // MARK: - Firestore Operations

    /// Load categories from Firestore, seed defaults if empty, then compute net amounts
    private func loadCategories() {
        guard let uid = uid else { return }
        db.collection("users").document(uid)
            .collection("categories")
            .getDocuments { snap, error in
                var fetched = snap?.documents.compactMap { $0.data()["name"] as? String } ?? []
                if fetched.isEmpty {
                    // seed default categories
                    fetched = defaultCategories
                    for name in defaultCategories {
                        db.collection("users").document(uid)
                          .collection("categories")
                          .addDocument(data: ["name": name])
                    }
                }
                categories = fetched
                loadSummary()
            }
    }

    /// Compute net spent vs earned per category
    private func loadSummary() {
        guard let uid = uid else { return }
        var spentTotals: [String: Double] = [:]
        var earnedTotals: [String: Double] = [:]
        let group = DispatchGroup()

        for category in categories {
            group.enter()
            // Query spends
            db.collection("users").document(uid)
              .collection("spends")
              .whereField("category", isEqualTo: category)
              .getDocuments { snap, _ in
                  let spent = snap?.documents
                      .compactMap { $0.data()["amount"] as? Double }
                      .reduce(0, +) ?? 0
                  spentTotals[category] = spent

                  // Query earns
                  db.collection("users").document(uid)
                    .collection("earns")
                    .whereField("category", isEqualTo: category)
                    .getDocuments { snapE, _ in
                        let earned = snapE?.documents
                            .compactMap { $0.data()["amount"] as? Double }
                            .reduce(0, +) ?? 0
                        earnedTotals[category] = earned
                        group.leave()
                    }
              }
        }

        group.notify(queue: .main) {
            var net: [String: Double] = [:]
            for category in categories {
                let spent = spentTotals[category] ?? 0
                let earned = earnedTotals[category] ?? 0
                net[category] = earned - spent
            }
            amounts = net
        }
    }

    /// Add a new category to Firestore
    private func addCategory() {
        guard let uid = uid else { return }
        let trimmed = newGroupName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !categories.contains(trimmed) else { return }
        db.collection("users").document(uid)
          .collection("categories")
          .addDocument(data: ["name": trimmed]) { error in
              if error == nil {
                  newGroupName = ""
                  loadCategories()
              }
          }
    }

    /// Delete categories and associated records from Firestore
    private func deleteCategories(at offsets: IndexSet) {
        guard let uid = uid else { return }
        let removed = offsets.map { categories[$0] }
        for cat in removed {
            // Delete category document
            db.collection("users").document(uid)
              .collection("categories")
              .whereField("name", isEqualTo: cat)
              .getDocuments { snap, _ in
                  snap?.documents.forEach { $0.reference.delete() }
              }
            // Delete linked spends
            db.collection("users").document(uid)
              .collection("spends")
              .whereField("category", isEqualTo: cat)
              .getDocuments { snap, _ in
                  snap?.documents.forEach { $0.reference.delete() }
              }
            // Delete linked earns
            db.collection("users").document(uid)
              .collection("earns")
              .whereField("category", isEqualTo: cat)
              .getDocuments { snap, _ in
                  snap?.documents.forEach { $0.reference.delete() }
                  // After deletion, reload
                  loadCategories()
              }
        }
    }
}

struct PersonPage_Previews: PreviewProvider {
    static var previews: some View {
        PersonPage()
    }
}
