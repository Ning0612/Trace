//
//  Components.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import SwiftUI

// MARK: - SectionHeader
struct SectionHeader: View {
    var title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title)
            .font(.title3).bold()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - MoodIconView
// 🔍 刪掉原本 Image(systemName:) 寫法，改回傳 Text emoji
struct MoodIconView: View {
    var score: Int
    var body: some View {
        Text(emoji(for: score))
            .font(.title2)
    }
    private func emoji(for s: Int) -> String {
        switch s {
        case ..<2: "😢"
        case 2:    "😐"
        case 3:    "🙂"
        case 4:    "😊"
        default:   "😄"
        }
    }
}

// MARK: - ProgressRingView
struct ProgressRingView: View {
    var progress: Double       // 0.0‒1.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(.gray.opacity(0.3), lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.blue, style: StrokeStyle(lineWidth: 8,
                                                  lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - JournalCardView
import SwiftData
struct JournalCardView: View {
    @Environment(\.modelContext) private var context
    @Bindable var entry: DiaryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.title)
                    .font(.headline)
                Spacer()
                Text(DateHelper.dateString(entry.date))
                    .font(.headline)
                Spacer()
                MoodIconView(score: entry.moodScore)
            }
            if !entry.text.isEmpty {
                Text(entry.text)
                    .lineLimit(3)
            }
            if let data = entry.imageData,
               let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(Color(.systemBackground)) 
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 1)
    }
}

// MARK: - GoalCardView
struct GoalCardView: View {
    @Environment(\.modelContext) private var context
    @Bindable var goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.title)
                    .font(.headline)
                Spacer()
                if let due = goal.targetDate {
                    Text("\(DateHelper.remainingDays(to: due)) 天")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if !goal.detail.isEmpty {
                Text(goal.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ProgressRingView(progress: goal.progress)
                .frame(width: 80, height: 80)

            Slider(value: $goal.progress, in: 0...1)
                .onChange(of: goal.progress) { _, _ in
                    try? context.save()
                }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 1)
    }
}

// MARK: - YearHeatmapView
struct YearHeatmapView: View {
    let countsByDate: [Date: Int]

    private let calendar = Calendar.current
    private var startOfYear: Date {
        calendar.date(from: DateComponents(year: calendar.component(.year, from: .now)))!
    }

    private var allDays: [Date] {
        (0..<365).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfYear) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Year in Review")
                .font(.title2).bold()

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(12), spacing: 3), count: 53), spacing: 3) {
                ForEach(allDays, id: \.self) { day in
                    let count = countsByDate[DateHelper.onlyDate(day)] ?? 0
                    Rectangle()
                        .foregroundStyle(color(for: count))
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.vertical)
            HStack {
                Text("少")
                Spacer()
                Text("多")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private func color(for count: Int) -> Color {
        switch count {
        case 0: Color.gray.opacity(0.2)
        case 1: Color.green.opacity(0.4)
        case 2: Color.green.opacity(0.6)
        case 3...5: Color.green
        default: Color.green.opacity(0.9)
        }
    }
}

// MARK: - MoodSummaryView
import SwiftData
import Charts

struct MoodSummaryView: View {
    var entries: [DiaryEntry]

    private var average: Double {
        guard !entries.isEmpty else { return 0 }
        return Double(entries.map(\.moodScore).reduce(0,+)) / Double(entries.count)
    }
    private var chartData: [(score: Int, count: Int)] {
        Dictionary(grouping: entries, by: \.moodScore)
            .map { ($0.key, $0.value.count) }
            .sorted { $0.score < $1.score }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("平均心情：\(String(format: "%.1f", average))")
                .font(.headline)

            Chart {
                ForEach(chartData, id: \.score) { item in
                    BarMark(
                        x: .value("心情", item.score),
                        y: .value("次數", item.count)
                    )
                }
            }
            .frame(height: 160)
        }
    }
}
