//
//  ContentView.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    var body: some View {
        if isFirstLaunch{
            OnBoardingView()
        }else {
            MainView()
        }
    }
}

#Preview {
    ContentView()
}
