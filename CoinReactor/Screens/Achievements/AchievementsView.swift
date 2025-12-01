//
//  AchievementsView.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var viewModel = AchievementsViewModel.shared
    @Environment(\.dismiss) var dismiss
    
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
                    
                    Text("ACHIEVEMENTS")
                        .foregroundStyle(.white)
                        .textCase(.uppercase)
                        .font(.system(size: 29, weight: .heavy, design: .monospaced))
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 60, height: 60)
                }
                .padding()
                
                // Summary
                HStack(spacing: 20) {
                    summaryCard(title: "Completed", value: "\(viewModel.completedCount)/\(viewModel.achievements.count)")
                    summaryCard(title: "Rewards", value: formatNumber(viewModel.totalRewardsAvailable))
                }
                .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.achievements) { achievement in
                            AchievementCell(
                                achievement: achievement,
                                onClaimReward: {
                                    let reward = viewModel.claimReward(for: achievement)
                                    return reward
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func summaryCard(title: String, value: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.lightBlueApp, lineWidth: 2)
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.blueApp.opacity(0.8))
            
            VStack(spacing: 5) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.gray)
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
            }
            .padding()
        }
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

struct AchievementCell: View {
    let achievement: AchievementsViewModel.Achievement
    let onClaimReward: () -> Int
    @State private var showRewardAlert = false
    @State private var rewardAmount = 0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(achievement.isCompleted ? Color.green : Color.lightBlueApp, lineWidth: 2)
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(achievement.isCompleted ? Color.green.opacity(0.2) : Color.blueApp.opacity(0.8))
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(achievement.title)
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                        
                        Text(achievement.description)
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    if achievement.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.system(size: 30))
                    }
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.lightBlueApp)
                            .frame(
                                width: max(0, geometry.size.width * CGFloat(achievement.progress)),
                                height: 12
                            )
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text("\(formatNumber(achievement.currentValue)) / \(formatNumber(achievement.targetValue))")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.gray)
                    
                    Spacer()
                    
                    if achievement.isCompleted && !achievement.rewardClaimed {
                        Button {
                            rewardAmount = onClaimReward()
                            showRewardAlert = true
                        } label: {
                            Text("Claim \(formatNumber(achievement.reward))")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    } else if achievement.rewardClaimed {
                        Text("Reward Claimed")
                            .font(.system(size: 12))
                            .foregroundStyle(.green)
                    } else {
                        Text("Reward: \(formatNumber(achievement.reward))")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding()
        }
        .alert("Reward Claimed!", isPresented: $showRewardAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You received \(formatNumber(rewardAmount)) coins!")
        }
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
    AchievementsView()
}

