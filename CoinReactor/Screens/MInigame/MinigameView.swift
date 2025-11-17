//
//  MinigameView.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI

struct MinigameView: View {
    @StateObject var viewModel = MiniGameViewModel()
    @ObservedObject var mainViewModel: MainViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            
            if viewModel.selectedLevel == nil {
                levelSelectionView
            } else {
                gameView
            }
        }.navigationBarBackButtonHidden()
    }
    
    private var levelSelectionView: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(.backBut)
                        .resizable()
                        .frame(width: 60, height: 60)
                }
                
                Spacer()
                
                Text("LEVELS")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.white)
                
                Spacer()
                
                Color.clear
                    .frame(width: 60, height: 60)
            }
            .padding()
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(viewModel.levels, id: \.number) { level in
                        LevelCell(
                            level: level,
                            onTap: {
                                viewModel.selectLevel(level.number)
                            }
                        )
                    }
                }
                .padding()
            }
        }
    }
    
    private var gameView: some View {
        VStack {
            HStack {
                Button {
                    viewModel.backToLevelSelection()
                } label: {
                    Image(.backBut)
                        .resizable()
                        .frame(width: 60, height: 60)
                }
                
                Spacer()
               
                
                VStack {
                    Text("\(viewModel.timeRemaining)")
                        .foregroundStyle(viewModel.timeRemaining <= 10 ? .red : .white)
                    Text("Find the pairs")
                        .foregroundStyle(.gray)
                }.font(.system(size: 20, weight: .heavy, design: .monospaced))
                Image(.backBut)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .opacity(0)
                //.frame(width: 40)
                Spacer()
            }
            .padding()
            
            Spacer()
            if let level = viewModel.levels.first(where: { $0.number == viewModel.selectedLevel }) {
                GameBoardView(
                    viewModel: viewModel,
                    rows: level.rows,
                    columns: level.columns
                )
            }
            
            Spacer()
        }
        .overlay {
            if viewModel.isGameWon {
                winOverlay
            } else if viewModel.isGameLost {
                loseOverlay
            }
        }
    }
    
    private var winOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Image(.victoryLabel)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Spacer()
                Button {
                    let reward = viewModel.getReward(for: viewModel.selectedLevel ?? 1)
                    mainViewModel.addCoins(reward)
                    viewModel.backToLevelSelection()
                } label: {
                    MainBlueButtonView(title: "Continue")
                }
            }
            .padding()
        }
    }
    
    private var loseOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                Image(.lossLabel)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Spacer()
                
                Button {
                    mainViewModel.addCoins(-1000)
                    viewModel.backToLevelSelection()
                } label: {
                    MainBlueButtonView(title: "Continue")
                }
            }
            .padding()
        }
    }
}



#Preview {
    MinigameView(mainViewModel: MainViewModel())
}
