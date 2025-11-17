//
//  MainBlueButtonView.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI

struct MainBlueButtonView: View {
    var title: String
    var height: CGFloat = 50
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.lightBlueApp)
            Text(title)
                .foregroundStyle(.white)
                .font(.title)
                .bold()
                .minimumScaleFactor(0.5)
                .padding(.horizontal)
        }.frame(height: height)
    }
}

#Preview {
    MainBlueButtonView(title: "150000000000000000000000000")
}
