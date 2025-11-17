//
//  GameBoardView.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI

struct GameBoardView: View {
    @ObservedObject var viewModel: MiniGameViewModel
    let rows: Int
    let columns: Int
    
    var body: some View {
       
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: columns), spacing: 10) {
                ForEach(viewModel.gameCards) { card in
                    CardView(card: card) {
                        viewModel.flipCard(at: card.id)
                    }
                }
            }
            .padding()
        
    }
}
