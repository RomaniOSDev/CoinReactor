//
//  StoreView.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI

struct StoreView: View {
    @StateObject var vm: MainViewModel
    var body: some View {
        ZStack{
            Color.blueApp.ignoresSafeArea()
            VStack{
                HStack{
                    Text("Store")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.white)
                    Spacer()
                }
            ScrollView {
                
                    ForEach(Coins.allCases, id: \.self) { coin in
                        StoreCellView(coins: coin, onBuy: { coin in
                            vm.byCoin(coin: coin)
                        }, isbuy: vm.getStatusByCoin(coin: coin))
                        .padding()
                    }
                }
            }.padding()
        }
    }
}

#Preview {
    StoreView(vm: MainViewModel())
}
