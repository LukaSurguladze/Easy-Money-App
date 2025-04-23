//
//  ReportPage.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI

struct ReportPage: View {
    @AppStorage("currentUser") private var currentUser: String = ""
    @State private var startDate = Date()
    @State private var endDate   = Date()
    @State private var totalSpent:  Double = 0
    @State private var totalEarned: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Report").font(.largeTitle)

            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
            DatePicker("End Date",   selection: $endDate,   displayedComponents: .date)

            Button("Generate Report") { generateReport() }
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(8)

            Text("Total Spent: $\(totalSpent, specifier: "%.2f")")
            Text("Total Earned: $\(totalEarned, specifier: "%.2f")")

            Spacer()
        }
        .padding()
        .navigationBarTitle("Reports", displayMode: .inline)
    }

    func generateReport() {
        totalSpent = 0; totalEarned = 0
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let cal = Calendar.current
        let s = cal.startOfDay(for: startDate)
        let e = cal.startOfDay(for: endDate)

        let allKeys = UserDefaults.standard.stringArray(forKey: "allDates_\(currentUser)") ?? []
        for dayKey in allKeys {
            // dayKey = "\(username)_yyyy-MM-dd"
            let parts = dayKey.split(separator: "_", maxSplits: 1)
            guard parts.count == 2,
                  let d = fmt.date(from: String(parts[1])),
                  d >= s && d <= e,
                  let dayData = UserDefaults.standard.dictionary(forKey: dayKey) as? [String:[String:Double]]
            else { continue }

            for catData in dayData.values {
                totalSpent  += catData["spent"]  ?? 0
                totalEarned += catData["earned"] ?? 0
            }
        }
    }
}
