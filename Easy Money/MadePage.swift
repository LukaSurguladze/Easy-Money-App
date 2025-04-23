//
//  MadePage.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI

struct MadePage: View {
    @AppStorage("currentUser") private var currentUser: String = ""
    @State private var categories: [String] = []
    @State private var amount = ""
    @State private var selectedCategory = ""
    @State private var selectedDate = Date()
    @State private var errorMessage = ""
    @State private var showConfirmation = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Enter the Amount Earned").font(.title)

            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { Text($0) }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 120)
            .clipped()

            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)

            Text(errorMessage).foregroundColor(.red).font(.footnote)

            Button("Enter") { saveAmount() }
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

            Spacer()
        }
        .padding()
        .navigationBarTitle("Earned", displayMode: .inline)
        .onAppear {
            loadCategories()
        }
        .alert("Success", isPresented: $showConfirmation) {
            Button("OK", action: dismiss.callAsFunction)
        } message: {
            Text("Your earned amount has been recorded.")
        }
    }

    private var categoriesKey: String { "categories_\(currentUser)" }
    private var datesKey: String      { "allDates_\(currentUser)" }

    private func loadCategories() {
        let saved = UserDefaults.standard.stringArray(forKey: categoriesKey)
        categories = saved ?? ["Food", "Bills", "Activities"]
        if selectedCategory.isEmpty, let first = categories.first {
            selectedCategory = first
        }
    }

    private func saveAmount() {
        guard let value = Double(amount), value > 0 else {
            errorMessage = "Please enter a valid amount."
            return
        }

        let dateKey = "\(currentUser)_\(getDateKey(from: selectedDate))"
        var dayData = UserDefaults.standard
            .dictionary(forKey: dateKey) as? [String:[String:Double]] ?? [:]

        var catData = dayData[selectedCategory] ?? ["spent":0, "earned":0]
        catData["earned"] = (catData["earned"] ?? 0) + value
        dayData[selectedCategory] = catData

        UserDefaults.standard.set(dayData, forKey: dateKey)

        var allDates = UserDefaults.standard.stringArray(forKey: datesKey) ?? []
        if !allDates.contains(dateKey) {
            allDates.append(dateKey)
            UserDefaults.standard.set(allDates, forKey: datesKey)
        }

        amount = ""
        errorMessage = ""
        showConfirmation = true
    }

    private func getDateKey(from date: Date) -> String {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }
}

struct MadePage_Previews: PreviewProvider {
    static var previews: some View {
        UserDefaults.standard.set(["bob"], forKey: "allUserCredentials")
        UserDefaults.standard.set("bob", forKey: "currentUser")
        UserDefaults.standard.set(["Food","Bills","Activities","Work"], forKey: "categories_bob")
        return MadePage()
    }
}
