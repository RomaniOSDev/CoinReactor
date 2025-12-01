//
//  StatisticsViewModel.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import Foundation
import Combine

final class StatisticsViewModel: ObservableObject {
    static let shared = StatisticsViewModel()
    
    private init() {
        self.storage = .standard
        loadStatistics()
        startSessionTracking()
    }
    @Published var totalCoinsEarned: Int = 0
    @Published var totalTaps: Int = 0
    @Published var totalPlayTime: TimeInterval = 0
    @Published var maxDailyEarnings: Int = 0
    @Published var bestMiniGameLevel: Int = 0
    @Published var dailyProgress: [DailyProgress] = []
    
    private let storage: UserDefaults
    private var startTime: Date?
    private var timer: Timer?
    
    private enum StorageKeys {
        static let totalCoinsEarned = "stats.totalCoinsEarned"
        static let totalTaps = "stats.totalTaps"
        static let totalPlayTime = "stats.totalPlayTime"
        static let maxDailyEarnings = "stats.maxDailyEarnings"
        static let bestMiniGameLevel = "stats.bestMiniGameLevel"
        static let dailyProgress = "stats.dailyProgress"
        static let sessionStartTime = "stats.sessionStartTime"
    }
    
    struct DailyProgress: Codable, Identifiable {
        let id: UUID
        let date: Date
        let coinsEarned: Int
        let taps: Int
        
        init(date: Date, coinsEarned: Int, taps: Int) {
            self.id = UUID()
            self.date = date
            self.coinsEarned = coinsEarned
            self.taps = taps
        }
    }
    
    
    deinit {
        stopSessionTracking()
    }
    
    func loadStatistics() {
        totalCoinsEarned = storage.integer(forKey: StorageKeys.totalCoinsEarned)
        totalTaps = storage.integer(forKey: StorageKeys.totalTaps)
        totalPlayTime = storage.double(forKey: StorageKeys.totalPlayTime)
        maxDailyEarnings = storage.integer(forKey: StorageKeys.maxDailyEarnings)
        bestMiniGameLevel = storage.integer(forKey: StorageKeys.bestMiniGameLevel)
        
        if let data = storage.data(forKey: StorageKeys.dailyProgress),
           let progress = try? JSONDecoder().decode([DailyProgress].self, from: data) {
            dailyProgress = progress
        }
    }
    
    func addCoins(_ amount: Int) {
        totalCoinsEarned += amount
        storage.set(totalCoinsEarned, forKey: StorageKeys.totalCoinsEarned)
        
        // Update daily progress
        updateDailyProgress(coinsEarned: amount, taps: 0)
        
        // Update max daily earnings
        let todayCoins = getTodayCoins()
        if todayCoins > maxDailyEarnings {
            maxDailyEarnings = todayCoins
            storage.set(maxDailyEarnings, forKey: StorageKeys.maxDailyEarnings)
        }
    }
    
    func addTap() {
        totalTaps += 1
        storage.set(totalTaps, forKey: StorageKeys.totalTaps)
        updateDailyProgress(coinsEarned: 0, taps: 1)
    }
    
    func updateBestMiniGameLevel(_ level: Int) {
        if level > bestMiniGameLevel {
            bestMiniGameLevel = level
            storage.set(bestMiniGameLevel, forKey: StorageKeys.bestMiniGameLevel)
        }
    }
    
    private func updateDailyProgress(coinsEarned: Int, taps: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let index = dailyProgress.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            var progress = dailyProgress[index]
            let updatedProgress = DailyProgress(
                date: progress.date,
                coinsEarned: progress.coinsEarned + coinsEarned,
                taps: progress.taps + taps
            )
            dailyProgress[index] = updatedProgress
        } else {
            let newProgress = DailyProgress(date: today, coinsEarned: coinsEarned, taps: taps)
            dailyProgress.append(newProgress)
        }
        
        // Keep only last 30 days
        if dailyProgress.count > 30 {
            dailyProgress = Array(dailyProgress.suffix(30))
        }
        
        saveDailyProgress()
    }
    
    private func saveDailyProgress() {
        if let data = try? JSONEncoder().encode(dailyProgress) {
            storage.set(data, forKey: StorageKeys.dailyProgress)
        }
    }
    
    private func getTodayCoins() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        if let progress = dailyProgress.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            return progress.coinsEarned
        }
        return 0
    }
    
    private func startSessionTracking() {
        if let savedStartTime = storage.object(forKey: StorageKeys.sessionStartTime) as? Date {
            startTime = savedStartTime
        } else {
            startTime = Date()
            storage.set(startTime, forKey: StorageKeys.sessionStartTime)
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updatePlayTime()
        }
    }
    
    private func stopSessionTracking() {
        timer?.invalidate()
        updatePlayTime()
        startTime = nil
        storage.removeObject(forKey: StorageKeys.sessionStartTime)
    }
    
    private func updatePlayTime() {
        guard let startTime = startTime else { return }
        let sessionTime = Date().timeIntervalSince(startTime)
        totalPlayTime += sessionTime
        storage.set(totalPlayTime, forKey: StorageKeys.totalPlayTime)
        self.startTime = Date()
        storage.set(self.startTime, forKey: StorageKeys.sessionStartTime)
    }
    
    func formatPlayTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func getWeeklyProgress() -> [DailyProgress] {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        return dailyProgress.filter { $0.date >= weekAgo }
    }
    
    func getMonthlyProgress() -> [DailyProgress] {
        let calendar = Calendar.current
        let now = Date()
        let monthAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        
        return dailyProgress.filter { $0.date >= monthAgo }
    }
}

