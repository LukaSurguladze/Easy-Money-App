//
//  ReportPage.swift
//  Easy Money
//
//  Created by Luka Surguladze on 4/18/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ReportPage: View {
    private let db = Firestore.firestore()
    private var uid: String? { Auth.auth().currentUser?.uid }
   
    @State private var startDate = Date()
    @State private var endDate   = Date()
    @State private var totalSpent:  Double = 0
    @State private var totalEarned: Double = 0
    @State private var errorMessage: String = ""

    var body: some View {
        GeometryReader{ geo in
            ZStack {
                Image("RPbackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(width: geo.size.width,
                           height: geo.size.height)
                
                VStack(spacing: 16) {
                    Text("Report")
                        .font(.custom("Chewy-Regular", size: 50))
                        .foregroundColor(.white)

                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .colorScheme(.dark)
                        .font(.custom("Chewy-Regular", size: 20))
                        .foregroundColor(.white)

                    DatePicker("End Date",   selection: $endDate,   displayedComponents: .date)
                        .colorScheme(.dark)
                        .font(.custom("Chewy-Regular", size: 20))
                        .foregroundColor(.white)

                    
                    Button("Generate Report") { generateReport() }
                        .font(.custom("Chewy-Regular", size: 20))
                        .foregroundColor(.white)

                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                    Text("Total Spent: $\(totalSpent, specifier: "%.2f")")
                        .font(.custom("Chewy-Regular", size: 20))
                        .foregroundColor(.white)

                    Text("Total Earned: $\(totalEarned, specifier: "%.2f")")
                        .font(.custom("Chewy-Regular", size: 20))
                        .foregroundColor(.white)

                    
                    Spacer()
                }
                .padding()
                
            }
        }
    }
        
    /// Queries Firestore for spend/earn docs in the date range (inclusive of end date)
        private func generateReport() {
            guard let uid = uid else {
                errorMessage = "User not logged in."
                return
            }
            errorMessage = ""
            totalSpent = 0
            totalEarned = 0

            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: startDate)
            let endOfNextDay = calendar.date(byAdding: .day, value: 1,
                                             to: calendar.startOfDay(for: endDate))!
            let startTs = Timestamp(date: startOfDay)
            let endTs   = Timestamp(date: endOfNextDay)

            // Fetch spends within [start, end)
            db.collection("users")
              .document(uid)
              .collection("spends")
              .whereField("date", isGreaterThanOrEqualTo: startTs)
              .whereField("date", isLessThan: endTs)
              .getDocuments { snapshot, error in
                  if let error = error {
                      errorMessage = error.localizedDescription
                  } else {
                      totalSpent = snapshot?.documents
                          .compactMap { $0.data()["amount"] as? Double }
                          .reduce(0, +) ?? 0
                  }
              }

            // Fetch earns within [start, end)
            db.collection("users")
              .document(uid)
              .collection("earns")
              .whereField("date", isGreaterThanOrEqualTo: startTs)
              .whereField("date", isLessThan: endTs)
              .getDocuments { snapshot, error in
                  if let error = error {
                      errorMessage = error.localizedDescription
                  } else {
                      totalEarned = snapshot?.documents
                          .compactMap { $0.data()["amount"] as? Double }
                          .reduce(0, +) ?? 0
                  }
              }
        }
    }

    struct ReportPage_Previews: PreviewProvider {
        static var previews: some View {
            ReportPage()
        }
    }
