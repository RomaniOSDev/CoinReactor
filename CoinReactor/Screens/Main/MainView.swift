//
//  MainView.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject var vm = MainViewModel()
    @State private var floatingRewards: [FloatingReward] = []
    
    private struct FloatingReward: Identifiable, Equatable {
        let id = UUID()
        let value: Int
        let position: CGPoint
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack {
                    Image(.mainBack)
                        .resizable()
                        .ignoresSafeArea()
                    
                    VStack {
                        //MARK: - Top header
                        HStack(alignment: .top){
                            Button {
                                vm.isPresentedStore.toggle()
                            } label: {
                                Image(.storebtn)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            
                            CounCoinsView(conisCount: vm.coinsBalance)
                            VStack{
                                NavigationLink {
                                   SettingsView()
                                } label: {
                                    Image(.settingbTN)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                NavigationLink {
                                    MinigameView(mainViewModel: vm)
                                } label: {
                                    Image(.gameBTN)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                
                            }
                        }
                        Spacer()
                        
                        //MARK: - Main click button
                        Button {
                            showFloatingReward(in: proxy.size)
                        } label: {
                            Image(vm.setCoin.imageCoin)
                                .resizable()
                                .frame(width: 240, height: 240)
                                .padding()
                        }
                        Spacer()
                        
                        //MARK: - bottom menu
                        ScrollView(.horizontal) {
                            HStack{
                                PowerUpCell(
                                    title: "Click",
                                    level: vm.level(for: .click),
                                    price: vm.price(for: .click),
                                    image: .clickBTN,
                                    isMaxed: vm.isPowerUpMaxed(.click)
                                ) {
                                    vm.upgradePowerUp(.click)
                                }
                                
                                PowerUpCell(
                                    title: "For tap",
                                    level: vm.level(for: .tap),
                                    price: vm.price(for: .tap),
                                    image: .tapBTN,
                                    isMaxed: vm.isPowerUpMaxed(.tap)
                                ) {
                                    vm.upgradePowerUp(.tap)
                                }
                                
                                PowerUpCell(
                                    title: "Speed",
                                    level: vm.level(for: .speed),
                                    price: vm.price(for: .speed),
                                    image: .speedBtn,
                                    isMaxed: vm.isPowerUpMaxed(.speed)
                                ) {
                                    vm.upgradePowerUp(.speed)
                                }
                                
                            }
                        }
                        
                    }
                    .padding()
                    
                    floatingRewardsLayer
                }
            }
        }
        .sheet(isPresented: $vm.isPresentedStore) {
            StoreView(vm: vm)
        }
    }
    
    
    private func showFloatingReward(in size: CGSize) {
        let rewardValue = vm.tapToCoin()
        let reward = FloatingReward(
            value: rewardValue,
            position: randomPosition(in: size)
        )
        withAnimation(.easeOut(duration: 0.6)) {
            floatingRewards.append(reward)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeIn(duration: 0.3)) {
                floatingRewards.removeAll { $0.id == reward.id }
            }
        }
    }
    
    private func randomPosition(in size: CGSize) -> CGPoint {
        let horizontalPadding: CGFloat = 60
        let verticalPadding: CGFloat = 160
        
        let minX = horizontalPadding
        let maxX = max(horizontalPadding, size.width - horizontalPadding)
        let minY = verticalPadding
        let maxY = max(verticalPadding, size.height - verticalPadding)
        
        return CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )
    }
    
    private var floatingRewardsLayer: some View {
        ZStack {
            ForEach(floatingRewards) { reward in
                Text("+\(reward.value)")
                    .font(.system(size: 36, weight: .heavy, design: .monospaced))
                    .foregroundStyle(Color.lightBlueApp)
                    .position(reward.position)
                    .transition(.opacity)
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    MainView()
}
