//
//  SpendPage.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI

struct SpendPage: View {
    // 1) Who’s logged in?
    @AppStorage("currentUser") private var currentUser: String = ""
    
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
    
    
    
    

    private var categoriesKey: String { "categories_\(currentUser)" }
    private var datesKey: String      { "allDates_\(currentUser)" }

    private func loadCategories() {
        let saved = UserDefaults.standard.stringArray(forKey: categoriesKey)
        categories = saved ?? ["Food", "Bills", "Activities"]
        // ensure we have a default selection if empty
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
        catData["spent"] = (catData["spent"] ?? 0) + value
        dayData[selectedCategory] = catData

        UserDefaults.standard.set(dayData, forKey: dateKey)

        // index the date
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

struct SpendPage_Previews: PreviewProvider {
    static var previews: some View {
        // Simulate a user for preview
        UserDefaults.standard.set(["alice"], forKey: "allUserCredentials")
        UserDefaults.standard.set("alice", forKey: "currentUser")
        UserDefaults.standard.set(["Food","Bills","Activities","Work"], forKey: "categories_alice")
        return SpendPage()
    }
}
