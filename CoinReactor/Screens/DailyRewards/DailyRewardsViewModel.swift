//
//  DailyRewardsViewModel.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import Foundation
import Combine

final class DailyRewardsViewModel: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var lastClaimDate: Date?
    @Published var rewards: [DailyReward] = []
    @Published var canClaimToday: Bool = false
    
    private let storage: UserDefaults
    
    struct DailyReward: Identifiable, Codable {
        let id: Int
        let day: Int
        let reward: Int
        var isClaimed: Bool
        var isAvailable: Bool
        
        init(day: Int, reward: Int) {
            self.id = day
            self.day = day
            self.reward = reward
            self.isClaimed = false
            self.isAvailable = false
        }
    }
    
    private enum StorageKeys {
        static let currentStreak = "dailyRewards.streak"
        static let lastClaimDate = "dailyRewards.lastClaimDate"
        static let rewards = "dailyRewards.rewards"
        static let currentDay = "dailyRewards.currentDay"
    }
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
        initializeRewards()
        loadData()
        checkDailyReward()
    }
    
    private func initializeRewards() {
        // 7 days of rewards with increasing amounts
        rewards = [
            DailyReward(day: 1, reward: 1_000),
            DailyReward(day: 2, reward: 2_000),
            DailyReward(day: 3, reward: 3_000),
            DailyReward(day: 4, reward: 5_000),
            DailyReward(day: 5, reward: 7_500),
            DailyReward(day: 6, reward: 10_000),
            DailyReward(day: 7, reward: 25_000) // Bonus for completing the week
        ]
    }
    
    func loadData() {
        currentStreak = storage.integer(forKey: StorageKeys.currentStreak)
        
        if let dateData = storage.object(forKey: StorageKeys.lastClaimDate) as? Date {
            lastClaimDate = dateData
        }
        
        if let data = storage.data(forKey: StorageKeys.rewards),
           let savedRewards = try? JSONDecoder().decode([DailyReward].self, from: data) {
            // Merge saved rewards with defaults
            for (index, reward) in rewards.enumerated() {
                if let saved = savedRewards.first(where: { $0.day == reward.day }) {
                    rewards[index] = saved
                }
            }
        }
    }
    
    func saveData() {
        storage.set(currentStreak, forKey: StorageKeys.currentStreak)
        storage.set(lastClaimDate, forKey: StorageKeys.lastClaimDate)
        
        if let data = try? JSONEncoder().encode(rewards) {
            storage.set(data, forKey: StorageKeys.rewards)
        }
    }
    
    func checkDailyReward() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastClaim = lastClaimDate else {
            // First time - can claim day 1
            canClaimToday = true
            updateRewardAvailability(day: 1)
            return
        }
        
        let lastClaimDay = calendar.startOfDay(for: lastClaim)
        let daysSinceLastClaim = calendar.dateComponents([.day], from: lastClaimDay, to: today).day ?? 0
        
        if daysSinceLastClaim == 0 {
            // Already claimed today
            canClaimToday = false
        } else if daysSinceLastClaim == 1 {
            // Consecutive day - continue streak
            canClaimToday = true
            let nextDay = min(currentStreak + 1, 7)
            updateRewardAvailability(day: nextDay)
        } else {
            // Streak broken - reset to day 1
            currentStreak = 0
            canClaimToday = true
            updateRewardAvailability(day: 1)
        }
    }
    
    private func updateRewardAvailability(day: Int) {
        for index in 0..<rewards.count {
            rewards[index].isAvailable = rewards[index].day == day && !rewards[index].isClaimed
        }
    }
    
    func claimReward(for reward: DailyReward) -> Int? {
        guard canClaimToday, reward.isAvailable, !reward.isClaimed else {
            return nil
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Mark reward as claimed
        if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
            rewards[index].isClaimed = true
            rewards[index].isAvailable = false
        }
        
        // Update streak
        if let lastClaim = lastClaimDate {
            let lastClaimDay = calendar.startOfDay(for: lastClaim)
            let daysSinceLastClaim = calendar.dateComponents([.day], from: lastClaimDay, to: today).day ?? 0
            
            if daysSinceLastClaim == 1 {
                // Consecutive day
                currentStreak += 1
            } else {
                // Streak broken
                currentStreak = 1
            }
        } else {
            // First claim
            currentStreak = 1
        }
        
        // If completed week, reset for next week
        if currentStreak >= 7 {
            resetWeekRewards()
            currentStreak = 0
        }
        
        lastClaimDate = today
        canClaimToday = false
        
        saveData()
        return reward.reward
    }
    
    private func resetWeekRewards() {
        for index in 0..<rewards.count {
            rewards[index].isClaimed = false
            rewards[index].isAvailable = false
        }
    }
    
    func getStreakBonus() -> Int {
        // Bonus based on streak
        switch currentStreak {
        case 3...6:
            return currentStreak * 500
        case 7:
            return 5_000
        default:
            return 0
        }
    }
    
    var nextRewardDay: Int {
        min(currentStreak + 1, 7)
    }
    
    var daysUntilNextReward: Int {
        guard let lastClaim = lastClaimDate else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        
        if calendar.isDateInToday(lastClaim) {
            return 1
        } else {
            return 0
        }
    }
}

