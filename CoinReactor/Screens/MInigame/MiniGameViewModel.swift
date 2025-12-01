//
//  MiniGameViewModel.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import Foundation
import Combine

struct GameLevel {
    let number: Int
    let rows: Int
    let columns: Int
    let timeLimit: Int // в секундах
    let isUnlocked: Bool
    
    var totalCards: Int {
        rows * columns
    }
}

final class MiniGameViewModel: ObservableObject {
    @Published var selectedLevel: Int?
    @Published var unlockedLevels: Set<Int> = [1]
    @Published var gameCards: [GameCard] = []
    @Published var flippedCards: Set<Int> = []
    @Published var matchedCards: Set<Int> = []
    @Published var timeRemaining: Int = 0
    @Published var isGameActive: Bool = false
    @Published var isGameWon: Bool = false
    @Published var isGameLost: Bool = false
    
    private var timer: Timer?
    private var currentLevel: GameLevel?
    private let storage: UserDefaults
    
    private enum StorageKeys {
        static let unlockedLevels = "minigame.unlockedLevels"
    }
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
        loadUnlockedLevels()
    }
    
    var levels: [GameLevel] {
        (1...10).map { levelNumber in
            let (rows, cols) = gridSize(for: levelNumber)
            let timeLimit = timeLimit(for: levelNumber)
            let isUnlocked = unlockedLevels.contains(levelNumber)
            return GameLevel(
                number: levelNumber,
                rows: rows,
                columns: cols,
                timeLimit: timeLimit,
                isUnlocked: isUnlocked
            )
        }
    }
    
    private func gridSize(for level: Int) -> (rows: Int, columns: Int) {
        switch level {
        case 1...3:
            return (2, 2)
        case 4...6:
            return (3, 3)
        case 7...10:
            return (4, 3)
        default:
            return (2, 2)
        }
    }
    
    private func timeLimit(for level: Int) -> Int {
        let baseTime = 30
        let reduction = (level - 1) * 2
        return max(15, baseTime - reduction)
    }
    
    func selectLevel(_ level: Int) {
        guard unlockedLevels.contains(level) else { return }
        selectedLevel = level
        startGame(level: level)
    }
    
    func startGame(level: Int) {
        guard let levelConfig = levels.first(where: { $0.number == level }) else { return }
        currentLevel = levelConfig
        
        resetGame()
        generateCards(for: levelConfig)
        timeRemaining = levelConfig.timeLimit
        isGameActive = true
        isGameWon = false
        isGameLost = false
        
        startTimer()
    }
    
    private func generateCards(for level: GameLevel) {
        let totalCards = level.totalCards
        let pairsNeeded = totalCards / 2
        
        var cardTypes: [Int] = []
        for i in 1...min(6, pairsNeeded) {
            cardTypes.append(i)
            cardTypes.append(i)
        }
        
        while cardTypes.count < totalCards {
            let randomType = Int.random(in: 1...6)
            cardTypes.append(randomType)
            cardTypes.append(randomType)
        }
        
        cardTypes.shuffle()
        
        gameCards = cardTypes.enumerated().map { index, type in
            GameCard(id: index, type: type, isFlipped: false, isMatched: false)
        }
    }
    
    func flipCard(at index: Int) {
        guard isGameActive,
              !isGameWon,
              !isGameLost,
              index < gameCards.count,
              !gameCards[index].isMatched,
              !gameCards[index].isFlipped,
              flippedCards.count < 2 else { return }
        
        var updatedCards = gameCards
        updatedCards[index].isFlipped = true
        gameCards = updatedCards
        flippedCards.insert(index)
        
        if flippedCards.count == 2 {
            checkMatch()
        }
    }
    
    private func checkMatch() {
        guard flippedCards.count == 2 else { return }
        
        let indices = Array(flippedCards)
        let card1 = gameCards[indices[0]]
        let card2 = gameCards[indices[1]]
        
        if card1.type == card2.type {
            matchedCards.insert(indices[0])
            matchedCards.insert(indices[1])
            var updatedCards = gameCards
            updatedCards[indices[0]].isMatched = true
            updatedCards[indices[1]].isMatched = true
            gameCards = updatedCards
            
            if matchedCards.count == gameCards.count {
                winGame()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.flipBackCards(indices: indices)
            }
        }
        
        flippedCards.removeAll()
    }
    
    private func flipBackCards(indices: [Int]) {
        var updatedCards = gameCards
        for index in indices {
            if index < updatedCards.count && !updatedCards[index].isMatched {
                updatedCards[index].isFlipped = false
            }
        }
        gameCards = updatedCards
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isGameActive else { return }
            
            self.timeRemaining -= 1
            
            if self.timeRemaining <= 0 {
                self.loseGame()
            }
        }
    }
    
    private func winGame() {
        isGameActive = false
        isGameWon = true
        timer?.invalidate()
        
        let level = currentLevel?.number ?? 1
        unlockNextLevel(level)
        
        // Update statistics
        StatisticsViewModel.shared.updateBestMiniGameLevel(level)
    }
    
    private func loseGame() {
        isGameActive = false
        isGameLost = true
        timer?.invalidate()
    }
    
    func resetGame() {
        gameCards = []
        flippedCards.removeAll()
        matchedCards.removeAll()
        timeRemaining = 0
        timer?.invalidate()
    }
    
    func backToLevelSelection() {
        resetGame()
        selectedLevel = nil
        isGameWon = false
        isGameLost = false
    }
    
    private func unlockNextLevel(_ completedLevel: Int) {
        let nextLevel = completedLevel + 1
        if nextLevel <= 10 {
            unlockedLevels.insert(nextLevel)
            persistUnlockedLevels()
        }
    }
    
    private func loadUnlockedLevels() {
        if let data = storage.array(forKey: StorageKeys.unlockedLevels) as? [Int] {
            unlockedLevels = Set(data)
        } else {
            unlockedLevels = [1]
            persistUnlockedLevels()
        }
    }
    
    private func persistUnlockedLevels() {
        storage.set(Array(unlockedLevels), forKey: StorageKeys.unlockedLevels)
    }
    
    func getReward(for level: Int) -> Int {
        return 1000 * level
    }
}

struct GameCard: Identifiable {
    let id: Int
    let type: Int
    var isFlipped: Bool
    var isMatched: Bool
}
