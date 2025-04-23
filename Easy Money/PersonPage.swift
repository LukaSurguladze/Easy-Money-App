//
//  PersonPage.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI

struct PersonPage: View {
    @AppStorage("currentUser") private var currentUser: String = ""
    @State private var categories: [String] = []
    @State private var amounts: [String: Double] = [:]

    @State private var newGroupName = ""
    @State private var showAddAlert = false
    @State private var isEditing = false

    var body: some View {
        VStack(spacing: 0) {
            Text("Your Categories")
                .font(.title)
                .padding(.top)

            List {
                ForEach(categories, id: \.self) { cat in
                    HStack {
                        Text(cat)
                        Spacer()
                        Text("$\(amounts[cat] ?? 0, specifier: "%.2f")")
                    }
                }
                .onDelete(perform: deleteCategories)
            }
            .listStyle(.insetGrouped)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button("Add New Category") {
                showAddAlert = true
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .navigationBarTitle("Summary", displayMode: .inline)
        .toolbar {
            // Edit/Done button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation { isEditing.toggle() }
                }
            }
        }
        .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive))
        .onAppear {
            loadCategories()
            loadSummary()
        }
        .alert("Add Category", isPresented: $showAddAlert) {
            TextField("Category Name", text: $newGroupName)
            Button("Add", action: addCategory)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter a new category name.")
        }
    }

    // MARK: - Keys

    private var categoriesKey: String { "categories_\(currentUser)" }
    private var datesKey:      String { "allDates_\(currentUser)"  }

    // MARK: - Load / Save

    private func loadCategories() {
        if let saved = UserDefaults.standard.stringArray(forKey: categoriesKey) {
            categories = saved
        } else {
            categories = ["Food", "Bills", "Activities"]
            UserDefaults.standard.set(categories, forKey: categoriesKey)
        }
    }

    private func loadSummary() {
        var spentTotals:  [String:Double] = [:]
        var earnedTotals: [String:Double] = [:]

        let allKeys = UserDefaults.standard.stringArray(forKey: datesKey) ?? []
        for dayKey in allKeys {
            guard
               let dayData = UserDefaults.standard
                 .dictionary(forKey: dayKey) as? [String:[String:Double]]
            else { continue }

            for cat in categories {
                if let d = dayData[cat] {
                    spentTotals[cat]  = (spentTotals[cat]  ?? 0) + (d["spent"]  ?? 0)
                    earnedTotals[cat] = (earnedTotals[cat] ?? 0) + (d["earned"] ?? 0)
                }
            }
        }

        var net: [String:Double] = [:]
        for cat in categories {
            net[cat] = (earnedTotals[cat] ?? 0) - (spentTotals[cat] ?? 0)
        }
        amounts = net
    }

    // MARK: - Actions

    private func addCategory() {
        let trimmed = newGroupName.trimmingCharacters(in: .whitespaces)
        guard
            !trimmed.isEmpty,
            !categories.contains(trimmed)
        else { return }
        categories.append(trimmed)
        UserDefaults.standard.set(categories, forKey: categoriesKey)
        newGroupName = ""
        loadSummary()
    }

    private func deleteCategories(at offsets: IndexSet) {
        // 1) Remove from the categories array
        let removed = offsets.map { categories[$0] }
        categories.remove(atOffsets: offsets)
        UserDefaults.standard.set(categories, forKey: categoriesKey)

        // 2) For each removed category, scrub past data
        let allKeys = UserDefaults.standard.stringArray(forKey: datesKey) ?? []

        for dayKey in allKeys {
            // Load that day’s data
            var dayData = UserDefaults.standard
                .dictionary(forKey: dayKey) as? [String:[String:Double]] ?? [:]

            // Remove any of the deleted categories
            var changed = false
            for cat in removed {
                if dayData.removeValue(forKey: cat) != nil {
                    changed = true
                }
            }

            // If it changed, write it back
            if changed {
                UserDefaults.standard.set(dayData, forKey: dayKey)
            }
        }

        // 3) Recompute the summary
        loadSummary()
    }
}

struct PersonPage_Previews: PreviewProvider {
    static var previews: some View {
        PersonPage()
            .onAppear {
                UserDefaults.standard.set("alice", forKey: "currentUser")
                UserDefaults.standard.set(["Food","Bills","Activities","Work"], forKey: "categories_alice")
                UserDefaults.standard.set(["alice_2025-04-22"], forKey: "allDates_alice")
                UserDefaults.standard.set(["Food":["spent":225.0,"earned":0.0]], forKey: "alice_2025-04-22")
            }
    }
}
