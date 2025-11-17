//
//  PowerUpCell.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI

struct PowerUpCell: View {
    
    var title: String
    var level: Int
    var price: Int
    var image: ImageResource
    var isMaxed: Bool
    var tapAction: () -> Void
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.lightBlueApp ,lineWidth: 1)
                    .shadow(color: .white, radius: 5)
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.blueApp)
            }.frame(height: 177)
            VStack{
                Image(image)
                    .resizable()
                    .frame(width: 100, height: 100)
                Text(title)
                    .font(.system(size: 24, weight: .heavy, design: .monospaced))
                    .foregroundStyle(.white)
                Text("\(level) level")
                    .font(.system(size: 18))
                    .foregroundStyle(.gray)
                Button {
                    tapAction()
                } label: {
                    MainBlueButtonView(title: isMaxed ? "MAX" : "\(price)", height: 40)
                }
                .disabled(isMaxed)

            }.padding()
        }.frame(width: 151)
    }
}

#Preview {
    PowerUpCell(title: "Click", level: 12, price: 50000, image: .clickBTN, isMaxed: false, tapAction: {})
}
