//
//  DailyRewardsView.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI

struct DailyRewardsView: View {
    @StateObject private var viewModel = DailyRewardsViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showRewardAlert = false
    @State private var rewardAmount = 0
    @StateObject private var mainViewModel = MainViewModel()
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(.backBut)
                            .resizable()
                            .frame(width: 60, height: 60)
                    }
                    
                    Spacer()
                    
                    Text("DAILY REWARDS")
                        .foregroundStyle(.white)
                        .textCase(.uppercase)
                        .font(.system(size: 29, weight: .heavy, design: .monospaced))
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 60, height: 60)
                }
                .padding()
                
                // Streak Info
                streakInfoCard
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 15) {
                        // Rewards Calendar
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(viewModel.rewards) { reward in
                                DailyRewardCell(
                                    reward: reward,
                                    currentStreak: viewModel.currentStreak,
                                    onClaim: {
                                        if let amount = viewModel.claimReward(for: reward) {
                                            rewardAmount = amount
                                            mainViewModel.addCoins(amount)
                                            showRewardAlert = true
                                            return amount
                                        }
                                        return nil
                                    }
                                )
                            }
                        }
                        .padding()
                        
                        // Info Card
                        infoCard
                            .padding(.horizontal)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .alert("Reward Claimed!", isPresented: $showRewardAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You received \(formatNumber(rewardAmount)) coins!")
        }
    }
    
    private var streakInfoCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.lightBlueApp, lineWidth: 2)
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.blueApp.opacity(0.8))
            
            HStack(spacing: 30) {
                VStack(spacing: 5) {
                    Text("STREAK")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.gray)
                    Text("\(viewModel.currentStreak)")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                    Text("days")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
                
                Divider()
                    .frame(height: 50)
                    .foregroundStyle(.gray.opacity(0.5))
                
                VStack(spacing: 5) {
                    Text("NEXT REWARD")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.gray)
                    Text("Day \(viewModel.nextRewardDay)")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundStyle(.lightBlueApp)
                    if viewModel.canClaimToday {
                        Text("Available Now!")
                            .font(.system(size: 10))
                            .foregroundStyle(.green)
                    } else {
                        Text("Come back tomorrow")
                            .font(.system(size: 10))
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding()
        }
    }
    
    private var infoCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.lightBlueApp, lineWidth: 2)
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.blueApp.opacity(0.8))
            
            VStack(alignment: .leading, spacing: 10) {
                Text("How it works")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    infoRow(text: "• Claim your reward every day to maintain your streak")
                    infoRow(text: "• Rewards increase each day")
                    infoRow(text: "• Complete 7 days for a bonus reward")
                    infoRow(text: "• Missing a day resets your streak")
                }
            }
            .padding()
        }
    }
    
    private func infoRow(text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundStyle(.gray)
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000.0)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000.0)
        } else {
            return "\(number)"
        }
    }
}

struct DailyRewardCell: View {
    let reward: DailyRewardsViewModel.DailyReward
    let currentStreak: Int
    let onClaim: () -> Int?
    @State private var showClaimed = false
    
    var isCurrentDay: Bool {
        reward.day == min(currentStreak + 1, 7)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    reward.isClaimed ? Color.green :
                    reward.isAvailable ? Color.lightBlueApp :
                    Color.gray.opacity(0.5),
                    lineWidth: reward.isAvailable ? 3 : 2
                )
            
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(
                    reward.isClaimed ? Color.green.opacity(0.2) :
                    reward.isAvailable ? Color.blueApp.opacity(0.9) :
                    Color.blueApp.opacity(0.5)
                )
            
            VStack(spacing: 8) {
                Text("Day \(reward.day)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                
                if reward.isClaimed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: 30))
                } else {
                    Text(formatNumber(reward.reward))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                    
                    if reward.isAvailable {
                        Button {
                            if let amount = onClaim() {
                                showClaimed = true
                            }
                        } label: {
                            Text("CLAIM")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .frame(height: 100)
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000.0)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000.0)
        } else {
            return "\(number)"
        }
    }
}

#Preview {
    DailyRewardsView()
}

