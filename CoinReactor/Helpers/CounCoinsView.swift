//
//  CounCoinsView.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI

struct CounCoinsView: View {
    var conisCount: Int
    var height: CGFloat = 60
    var body: some View {
       ZStack {
           Image(.backForCoin)
               .resizable()
               .aspectRatio(contentMode: .fit)
           Text("\(conisCount)")
               .foregroundStyle(.white)
               .minimumScaleFactor(0.5)
               .font(.system(size: height/2.2, weight: .heavy, design: .monospaced))
               .lineLimit(1)
               .padding()
        }
       .frame(width: height*3, height: height)
    }
}

#Preview {
    CounCoinsView(conisCount: 25550)
}
