//
//  OnBoardingView.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI

struct OnBoardingView: View {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @State private var currentPage: Int = 0
    
    var body: some View {
       
            
            TabView(selection: $currentPage) {
                OnBoardingPage(
                    image: .onboard1,
                    text: "An exciting clicker with pumping",
                    pageIndex: 0,
                    currentPage: $currentPage,
                    isFirstLaunch: $isFirstLaunch
                )
                .tag(0)
                
                OnBoardingPage(
                    image: .onboard2,
                    text: "Tap coins to earn rewards!",
                    pageIndex: 1,
                    currentPage: $currentPage,
                    isFirstLaunch: $isFirstLaunch
                )
                .tag(1)
                
                OnBoardingPage(
                    image: .onboard3,
                    text: "Upgrade your power-ups and become the best!",
                    pageIndex: 2,
                    currentPage: $currentPage,
                    isFirstLaunch: $isFirstLaunch
                )
                .tag(2)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .ignoresSafeArea()
        
    }
}

struct OnBoardingPage: View {
    let image: ImageResource
    let text: String
    let pageIndex: Int
    @Binding var currentPage: Int
    @Binding var isFirstLaunch: Bool
    
    var body: some View {
        ZStack{
            Image(image)
                .resizable()
                .ignoresSafeArea()
            VStack(spacing: 40) {
                Spacer()
                
               
                
                Text(text)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                                
                Button {
                    if pageIndex < 2 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        isFirstLaunch = false
                    }
                } label: {
                    MainBlueButtonView(title: "Continue")
                }
                .padding()
            }
        }
    }
}

#Preview {
    OnBoardingView()
}
