//
//  MainViewModel.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import Foundation
import Combine

final class MainViewModel: ObservableObject {
    enum PowerUpType: String, CaseIterable {
        case click
        case tap
        case speed
        
        var basePrice: Int {
            switch self {
            case .click: return 50_000
            case .tap: return 30_000
            case .speed: return 10_000
            }
        }
        
        var growthRate: Double {
            switch self {
            case .click: return 1.45
            case .tap: return 1.35
            case .speed: return 1.25
            }
        }
        
        static let maxLevel: Int = 25
    }
    
    @Published var isPresentedStore: Bool = false
    @Published var setCoin: Coins
    @Published private(set) var coinsBalance: Int
    @Published private(set) var powerUpLevels: [PowerUpType: Int]
    
    private var ownedCoins: Set<Coins>
    private let storage: UserDefaults
    private var autoTapCancellable: AnyCancellable?
    
    private enum StorageKeys {
        static let balance = "main.balance"
        static let ownedCoins = "main.ownedCoins"
        static let selectedCoin = "main.selectedCoin"
        static let powerUps = "main.powerUps"
    }
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
        
        let savedBalance = storage.integer(forKey: StorageKeys.balance)
        self.coinsBalance = savedBalance
        
        if let rawValue = storage.string(forKey: StorageKeys.selectedCoin),
           let savedCoin = Coins(rawValue: rawValue) {
            self.setCoin = savedCoin
        } else {
            self.setCoin = .blue
        }
        
        let savedOwned: Set<Coins>
        if let rawValues = storage.array(forKey: StorageKeys.ownedCoins) as? [String] {
            savedOwned = Set(rawValues.compactMap(Coins.init))
        } else {
            savedOwned = []
        }
        let shouldPersistOwnedCoins = !savedOwned.contains(.blue)
        var preparedOwned = savedOwned
        preparedOwned.insert(.blue)
        self.ownedCoins = preparedOwned
        
        if let savedPowerUps = storage.dictionary(forKey: StorageKeys.powerUps) as? [String: Int] {
            var levels: [PowerUpType: Int] = [:]
            savedPowerUps.forEach { key, value in
                guard let type = PowerUpType(rawValue: key) else { return }
                levels[type] = min(PowerUpType.maxLevel, value)
            }
            self.powerUpLevels = levels
        } else {
            self.powerUpLevels = [:]
        }
        
        if shouldPersistOwnedCoins {
            persistOwnedCoins()
        }
        
        startAutoTapTimer()
    }
    
    deinit {
        autoTapCancellable?.cancel()
    }
    
    @discardableResult
    func tapToCoin() -> Int {
        let reward = manualTapReward()
        coinsBalance += reward
        persistBalance()
        return reward
    }
    
    func addCoins(_ amount: Int) {
        coinsBalance += amount
        persistBalance()
    }
    
    func byCoin(coin: Coins) {
        if ownedCoins.contains(coin) {
            guard setCoin != coin else { return }
            setCoin = coin
            persistSelectedCoin()
            return
        }
        
        guard coinsBalance >= coin.price else { return }
        
        coinsBalance -= coin.price
        ownedCoins.insert(coin)
        setCoin = coin
        
        persistBalance()
        persistOwnedCoins()
        persistSelectedCoin()
    }
    
    func getStatusByCoin(coin: Coins) -> Bool {
        ownedCoins.contains(coin)
    }
    
    func level(for type: PowerUpType) -> Int {
        powerUpLevels[type, default: 0]
    }
    
    func isPowerUpMaxed(_ type: PowerUpType) -> Bool {
        level(for: type) >= PowerUpType.maxLevel
    }
    
    func price(for type: PowerUpType) -> Int {
        guard !isPowerUpMaxed(type) else { return 0 }
        let level = Double(level(for: type))
        return Int(Double(type.basePrice) * pow(type.growthRate, level))
    }
    
    func upgradePowerUp(_ type: PowerUpType) {
        guard !isPowerUpMaxed(type) else { return }
        let cost = price(for: type)
        guard coinsBalance >= cost else { return }
        
        coinsBalance -= cost
        powerUpLevels[type, default: 0] += 1
        
        persistBalance()
        persistPowerUps()
        
        if type == .click || type == .speed {
            startAutoTapTimer()
        }
    }
    
    private func manualTapReward() -> Int {
        let baseReward = 10.0 * setCoin.power
        let tapLevel = Double(level(for: .tap))
        let multiplier = 1.0 + tapLevel * 0.25
        return Int((baseReward * multiplier).rounded())
    }
    
    private func autoTapAmount() -> Int {
        let clickLevel = max(1, level(for: .click))
        let baseReward = 10.0 * setCoin.power
        let amount = baseReward * Double(clickLevel)
        return Int(amount.rounded())
    }
    
    private func autoTapInterval() -> TimeInterval {
        let baseInterval: Double = 1.5
        let reductionPerLevel: Double = 0.04
        let speedLevel = Double(level(for: .speed))
        let interval = baseInterval - reductionPerLevel * speedLevel
        return max(0.2, interval)
    }
    
    private func startAutoTapTimer() {
        autoTapCancellable?.cancel()
        guard level(for: .click) > 0 || level(for: .speed) > 0 else { return }
        
        let interval = autoTapInterval()
        autoTapCancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.applyAutoTap()
            }
    }
    
    private func applyAutoTap() {
        let amount = autoTapAmount()
        guard amount > 0 else { return }
        coinsBalance += amount
        persistBalance()
    }
    
    private func persistBalance() {
        storage.set(coinsBalance, forKey: StorageKeys.balance)
    }
    
    private func persistOwnedCoins() {
        let rawValues = ownedCoins.map(\.rawValue)
        storage.set(rawValues, forKey: StorageKeys.ownedCoins)
    }
    
    private func persistSelectedCoin() {
        storage.set(setCoin.rawValue, forKey: StorageKeys.selectedCoin)
    }
    
    private func persistPowerUps() {
        var raw: [String: Int] = [:]
        powerUpLevels.forEach { raw[$0.rawValue] = $1 }
        storage.set(raw, forKey: StorageKeys.powerUps)
    }
}
