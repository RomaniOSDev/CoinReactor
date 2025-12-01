//
//  AchievementsViewModel.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import Foundation
import Combine

final class AchievementsViewModel: ObservableObject {
    static let shared = AchievementsViewModel()
    @Published var achievements: [Achievement] = []
    
    private let storage: UserDefaults
    
    struct Achievement: Identifiable, Codable {
        let id: String
        let title: String
        let description: String
        let targetValue: Int
        var currentValue: Int
        var isCompleted: Bool
        let reward: Int
        var rewardClaimed: Bool
        
        init(id: String, title: String, description: String, targetValue: Int, reward: Int) {
            self.id = id
            self.title = title
            self.description = description
            self.targetValue = targetValue
            self.currentValue = 0
            self.isCompleted = false
            self.reward = reward
            self.rewardClaimed = false
        }
        
        var progress: Double {
            min(1.0, Double(currentValue) / Double(targetValue))
        }
    }
    
    private enum StorageKeys {
        static let achievements = "achievements.list"
    }
    
    private init(storage: UserDefaults = .standard) {
        self.storage = storage
        initializeAchievements()
        loadAchievements()
    }
    
    private func initializeAchievements() {
        achievements = [
            Achievement(
                id: "first_steps",
                title: "First Steps",
                description: "Earn 1,000 coins",
                targetValue: 1_000,
                reward: 500
            ),
            Achievement(
                id: "magnate",
                title: "Magnate",
                description: "Earn 1,000,000 coins",
                targetValue: 1_000_000,
                reward: 50_000
            ),
            Achievement(
                id: "clicker_master",
                title: "Clicker Master",
                description: "Make 10,000 taps",
                targetValue: 10_000,
                reward: 5_000
            ),
            Achievement(
                id: "collector",
                title: "Collector",
                description: "Buy all coins",
                targetValue: Coins.allCases.count,
                reward: 100_000
            ),
            Achievement(
                id: "max_upgrade",
                title: "Max Upgrade",
                description: "Upgrade all power-ups to maximum",
                targetValue: MainViewModel.PowerUpType.allCases.count * MainViewModel.PowerUpType.maxLevel,
                reward: 200_000
            ),
            Achievement(
                id: "dedicated_player",
                title: "Dedicated Player",
                description: "Play for 10 hours",
                targetValue: 36000, // 10 hours in seconds
                reward: 25_000
            ),
            Achievement(
                id: "speed_demon",
                title: "Speed Demon",
                description: "Upgrade Speed to maximum",
                targetValue: MainViewModel.PowerUpType.maxLevel,
                reward: 30_000
            ),
            Achievement(
                id: "millionaire",
                title: "Millionaire",
                description: "Earn 10,000,000 coins",
                targetValue: 10_000_000,
                reward: 500_000
            )
        ]
    }
    
    func loadAchievements() {
        if let data = storage.data(forKey: StorageKeys.achievements),
           let savedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            // Merge saved progress with defaults, but keep English titles/descriptions
            for (index, achievement) in achievements.enumerated() {
                if let saved = savedAchievements.first(where: { $0.id == achievement.id }) {
                    // Only update progress values, keep English title and description
                    achievements[index].currentValue = saved.currentValue
                    achievements[index].isCompleted = saved.isCompleted
                    achievements[index].rewardClaimed = saved.rewardClaimed
                }
            }
        }
    }
    
    func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            storage.set(data, forKey: StorageKeys.achievements)
        }
    }
    
    func updateAchievement(id: String, value: Int) {
        guard let index = achievements.firstIndex(where: { $0.id == id }) else { return }
        
        var achievement = achievements[index]
        achievement.currentValue = value
        achievement.isCompleted = value >= achievement.targetValue
        
        achievements[index] = achievement
        saveAchievements()
    }
    
    func claimReward(for achievement: Achievement) -> Int {
        guard let index = achievements.firstIndex(where: { $0.id == achievement.id }),
              achievement.isCompleted,
              !achievement.rewardClaimed else {
            return 0
        }
        
        achievements[index].rewardClaimed = true
        saveAchievements()
        return achievement.reward
    }
    
    func updateFromStatistics(totalCoins: Int, totalTaps: Int, playTime: TimeInterval) {
        updateAchievement(id: "first_steps", value: totalCoins)
        updateAchievement(id: "magnate", value: totalCoins)
        updateAchievement(id: "millionaire", value: totalCoins)
        updateAchievement(id: "clicker_master", value: totalTaps)
        updateAchievement(id: "dedicated_player", value: Int(playTime))
    }
    
    func updateCollectorAchievement(ownedCoins: Int) {
        updateAchievement(id: "collector", value: ownedCoins)
    }
    
    func updateMaxUpgradeAchievement(totalLevels: Int) {
        updateAchievement(id: "max_upgrade", value: totalLevels)
    }
    
    func updateSpeedDemonAchievement(speedLevel: Int) {
        updateAchievement(id: "speed_demon", value: speedLevel)
    }
    
    var completedCount: Int {
        achievements.filter { $0.isCompleted }.count
    }
    
    var totalRewardsAvailable: Int {
        achievements.filter { $0.isCompleted && !$0.rewardClaimed }.reduce(0) { $0 + $1.reward }
    }
}

