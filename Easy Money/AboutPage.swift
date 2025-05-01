//
//  AboutPage.swift
//  Easy Money
//
//  Created by Luka Surguladze on 5/1/25.
//

import SwiftUI

struct AboutPage: View {
    var body: some View {
        ZStack {
            Image("HPbackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    Text("About Pocket Insight")
                        .font(.custom("Chewy-Regular", size: 40))
                        .foregroundColor(.black)
                    
                    Image("AboutImage") // Replace with the name of your image in Assets.xcassets
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                                .cornerRadius(15)

                    Text("Luka Surguladze: Developer and Designer")
                        .font(.custom("Chewy-Regular", size: 20))
                        .foregroundColor(.black)
                        //.padding(.horizontal, 50)
                    
                    Spacer()
                    Spacer()
                    
                    Text("""
                         According to CBS News, a study found that 59% of Americans in 2025 do not have enough savings to cover an unexpected $1,000 emergency expense. That’s why here at Pocket Insight, our mission is to start teaching children and young adults how to budget their money. We believe that no matter what background you come from or where you are in life, budgeting your income and expenses can save you from disaster. No one should feel alone when it comes to money. Pocket Insight is your partner in building a better financial future—giving you the tools and confidence to take control of your finances, one step at a time.
                         """)
                                        .font(.custom("Chewy-Regular", size: 20))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 50)
                                    }
                                    .padding()
                                }
                            }
        
        .onAppear {
                   let appearance = UINavigationBarAppearance()
                   appearance.configureWithTransparentBackground()
                   appearance.backgroundColor = .clear
                   UINavigationBar.appearance().standardAppearance = appearance
                   UINavigationBar.appearance().scrollEdgeAppearance = appearance
               }
        
        
                        }
                    }
