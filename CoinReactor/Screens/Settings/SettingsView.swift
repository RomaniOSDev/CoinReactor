//
//  SettingsView.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var privacy: String = "Privacy Policy"
    @State private var terms: String = "Terms of Service"
    var body: some View {
        ZStack{
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            VStack{
                HStack{
                    Button {
                        dismiss()
                    } label: {
                        Image(.backBut)
                            .resizable()
                            .frame(width: 60, height: 60)
                    }
                    Spacer()
                    Text("Settings")
                        .foregroundStyle(.white)
                        .textCase(.uppercase)
                        .font(.system(size: 29, weight: .heavy, design: .monospaced))
                    Spacer()
                    Image(.backBut)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .opacity(0)
                }
                Spacer()
                
                VStack(spacing: 40){
                    Button {
                        SKStoreReviewController.requestReview()
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 2)
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(.blueApp)
                            Text("Rate us")
                                .foregroundStyle(.white)
                                .font(.system(size: 20, weight: .heavy, design: .monospaced))
                        }
                        .frame(height: 61)
                    }
                    Button {
                       if let url = URL(string: privacy) {
                        UIApplication.shared.open(url)
                        }
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 2)
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(.blueApp)
                            Text("Privacy Policy")
                                .foregroundStyle(.white)
                                .font(.system(size: 20, weight: .heavy, design: .monospaced))
                        }
                        .frame(height: 61)
                    }
                    Button {
                        if let url = URL(string: terms) {
                         UIApplication.shared.open(url)
                         }
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 2)
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(.blueApp)
                            Text("Terms of Use")
                                .foregroundStyle(.white)
                                .font(.system(size: 20, weight: .heavy, design: .monospaced))
                        }
                        .frame(height: 61)
                    }

                }
                Spacer()
            }.padding()
                .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    SettingsView()
}
