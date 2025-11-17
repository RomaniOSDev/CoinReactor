//
//  LevelCell.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI

struct LevelCell: View {
    let level: GameLevel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.blueApp)
                    .frame(height: 100)
                    .opacity(level.isUnlocked ? 0.5 : 1)
                 
                if level.isUnlocked{
                    Text("\(level.number)")
                        .font(.system(size: 46, weight: .heavy, design: .monospaced))
                        .foregroundStyle(.white)
                }else {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 34)
                }
                    
              
            }
        }
        .disabled(!level.isUnlocked)
    }
}
