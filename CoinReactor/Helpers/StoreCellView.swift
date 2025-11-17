//
//  StoreCellView.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI

struct StoreCellView: View {
    var coins: Coins
    var onBuy: (Coins) -> Void
    var isbuy: Bool
    var body: some View {
        ZStack(alignment: .bottom){
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.lightBlueApp, lineWidth: 1)
                    .shadow(color: .white, radius: 5)
                RoundedRectangle(cornerRadius: 20).foregroundStyle(.blueApp)
                
            }
            .frame(height: 220)
            VStack{
                HStack{
                    Image(coins.imageCoin)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    VStack{
                        Text(coins.rawValue + " coin")
                        Text("x\(coins.power)")
                            .opacity(0.6)
                    }
                    .foregroundStyle(.white)
                    .textCase(.uppercase)
                    .font(.system(size: 24, weight: .heavy, design: .monospaced))
                    .padding(.top, 40)
                }
                Button {
                    onBuy(coins)
                } label: {
                    MainBlueButtonView(title: isbuy ? "Employ" : "\(coins.price)")
                        .opacity(isbuy ? 0.3 : 1)
                }

            }.padding()
        }
    }
}

#Preview {
    ZStack{
        Color.blueApp
        StoreCellView(coins: Coins.blue, onBuy: {_ in }, isbuy: true)
            .padding()
    }
}
