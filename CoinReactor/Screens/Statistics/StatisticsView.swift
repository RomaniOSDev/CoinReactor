//
//  StatisticsView.swift
//  CoinReactor
//
//  Created by Роман Главацкий on 17.11.2025.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel.shared
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
                    
                    Text("STATISTICS")
                        .foregroundStyle(.white)
                        .textCase(.uppercase)
                        .font(.system(size: 29, weight: .heavy, design: .monospaced))
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 60, height: 60)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Overall Statistics
                        statisticsCard(title: "Overall Statistics") {
                            VStack(spacing: 15) {
                                statRow(title: "Total Coins Earned", value: formatNumber(viewModel.totalCoinsEarned))
                                statRow(title: "Total Taps", value: formatNumber(viewModel.totalTaps))
                                statRow(title: "Play Time", value: viewModel.formatPlayTime(viewModel.totalPlayTime))
                            }
                        }
                        
                        // Records
                        statisticsCard(title: "Records") {
                            VStack(spacing: 15) {
                                statRow(title: "Max Daily Earnings", value: formatNumber(viewModel.maxDailyEarnings))
                                statRow(title: "Best Mini Game Level", value: "\(viewModel.bestMiniGameLevel)")
                            }
                        }
                        
                        // Weekly Progress Chart
                        if !viewModel.getWeeklyProgress().isEmpty {
                            statisticsCard(title: "Weekly Progress") {
                                weeklyChart
                            }
                        }
                        
                        // Monthly Progress Chart
                        if !viewModel.getMonthlyProgress().isEmpty {
                            statisticsCard(title: "Monthly Progress") {
                                monthlyChart
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func statisticsCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: 24, weight: .heavy, design: .monospaced))
                .foregroundStyle(.white)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.lightBlueApp, lineWidth: 2)
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.blueApp.opacity(0.8))
                
                content()
                    .padding()
            }
        }
    }
    
    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.gray)
                .font(.system(size: 16, weight: .medium))
            Spacer()
            Text(value)
                .foregroundStyle(.white)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
        }
    }
    
    private var weeklyChart: some View {
        let progress = viewModel.getWeeklyProgress()
        
        return VStack(alignment: .leading, spacing: 10) {
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(progress) { day in
                        BarMark(
                            x: .value("Day", day.date, unit: .day),
                            y: .value("Coins", day.coinsEarned)
                        )
                        .foregroundStyle(.lightBlueApp)
                    }
                }
                .frame(height: 200)
            } else {
                // Fallback for iOS < 16
                VStack(spacing: 5) {
                    ForEach(progress.prefix(7)) { day in
                        HStack {
                            Text(day.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .frame(width: 80, alignment: .leading)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 20)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.lightBlueApp)
                                        .frame(
                                            width: max(0, geometry.size.width * CGFloat(day.coinsEarned) / CGFloat(max(progress.map { $0.coinsEarned }.max() ?? 1, 1))),
                                            height: 20
                                        )
                                }
                            }
                            .frame(height: 20)
                            
                            Text(formatNumber(day.coinsEarned))
                                .font(.caption)
                                .foregroundStyle(.white)
                                .frame(width: 60, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }
    
    private var monthlyChart: some View {
        let progress = viewModel.getMonthlyProgress()
        
        return VStack(alignment: .leading, spacing: 10) {
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(progress) { day in
                        BarMark(
                            x: .value("Day", day.date, unit: .day),
                            y: .value("Coins", day.coinsEarned)
                        )
                        .foregroundStyle(.lightBlueApp)
                    }
                }
                .frame(height: 200)
            } else {
                // Fallback for iOS < 16
                VStack(spacing: 5) {
                    ForEach(progress.prefix(10)) { day in
                        HStack {
                            Text(day.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .frame(width: 80, alignment: .leading)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 20)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.lightBlueApp)
                                        .frame(
                                            width: max(0, geometry.size.width * CGFloat(day.coinsEarned) / CGFloat(max(progress.map { $0.coinsEarned }.max() ?? 1, 1))),
                                            height: 20
                                        )
                                }
                            }
                            .frame(height: 20)
                            
                            Text(formatNumber(day.coinsEarned))
                                .font(.caption)
                                .foregroundStyle(.white)
                                .frame(width: 60, alignment: .trailing)
                        }
                    }
                }
            }
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
    StatisticsView()
}

