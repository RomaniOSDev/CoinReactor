//
//  CardView.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI

struct CardView: View {
    let card: GameCard
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
                if card.isFlipped || card.isMatched {
                    Image(cardImageName(for: card.type))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .opacity(card.isMatched ? 0.5 : 1.0)
                } else {
                    Image(.cardClose)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
            
        }
        .disabled(card.isMatched || card.isFlipped)
    }
    
    private func cardImageName(for type: Int) -> ImageResource {
        switch type {
        case 1: return .card1
        case 2: return .card2
        case 3: return .card3
        case 4: return .card4
        case 5: return .card5
        case 6: return .card6
        default: return .card1
        }
    }
}
