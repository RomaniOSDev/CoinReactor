//
//  CoinsEnum.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

enum Coins: String, CaseIterable {
    case blue
    case red
    case pink
    case green
    case purple
    case black
    
    var imageCoin: ImageResource{
        switch self {
            
        case .blue:
            return .blueCoin
        case .red:
            return .redCoin
        case .pink:
            return .pinkCoin
        case .green:
            return .greenCoin
        case .purple:
            return .peprleCoin
        case .black:
            return .blackCoin
        }
    }
    
    var price: Int {
        switch self {
        case .blue:
            return 0
        case .red:
            return 5000
        case .pink:
            return 10000000
        case .green:
            return 65000
        case .purple:
            return 150000
        case .black:
            return 90000000
        }
    }
    
    var power: Double {
        switch self {
            
        case .blue:
            1.1
        case .red:
            2.3
        case .pink:
            6.5
        case .green:
            3.0
        case .purple:
            5.0
        case .black:
            10.0
        }
    }
}
