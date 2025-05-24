//
//  Components.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import SwiftUI
import Charts
import SwiftData

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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title).font(.headline).foregroundColor(.primary)
                if let g = entry.goal {
                    Text("🔗 \(g.title)").font(.caption)
                }
                Text(entry.text).lineLimit(1).font(.subheadline)
            }
            Spacer()
            VStack {
                MoodIconView(score: entry.moodScore)
                Text(DateHelper.dateString(entry.date)).font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground)).foregroundColor(.primary) 
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
                    let day = DateHelper.remainingDays(to: due)          // ← ① 新增
                    Text(day >= 0 ? "剩 \(day) 天" : "已超過 \(abs(day)) 天") // ← ② 改這行
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
    let counts: [Date: Int]

    private let cal = Calendar.current
    private var startOfYear: Date {
        cal.date(from: DateComponents(year: cal.component(.year, from: .now)))!
    }

    /// 52 週 × 7 列
    private var allDays: [Date] {
        (0..<371).compactMap { cal.date(byAdding: .day, value: $0, to: startOfYear) }
    }

    private func color(_ c: Int) -> Color {
        switch c {
        case 0:  return Color.gray.opacity(0.12)
        case 1:  return Color.green.opacity(0.4)
        case 2:  return Color.green.opacity(0.6)
        case 3:  return Color.green.opacity(0.8)
        default: return Color.green
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            // 週列
            ForEach(0..<53, id: \.self) { w in
                VStack(spacing: 4) {
                    ForEach(0..<7, id: \.self) { d in
                        if let day = cal.date(byAdding: .day,
                                              value: w*7 + d,
                                              to: startOfYear),
                           cal.component(.year, from: day) == cal.component(.year, from: .now) {
                            Rectangle()
                                .fill(color(counts[DateHelper.onlyDate(day)] ?? 0))
                                .frame(width: 10, height: 10)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .overlay(weekdayOverlay, alignment: .leading)
        .overlay(monthOverlay, alignment: .topLeading)
    }

    // 左側 Mon / Wed / Fri
    private var weekdayOverlay: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("Mon").font(.caption2)
            Text("Wed").font(.caption2)
            Text("Fri").font(.caption2)
        }
        .foregroundStyle(.secondary)
    }

    private var monthOverlay: some View {
        HStack(spacing: 30) {
            ForEach(["Jan","Feb","Mar","Apr","May","Jun",
                     "Jul","Aug","Sep","Oct","Nov","Dec"], id: \.self) {
                Text($0).font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(.leading, 18)
    }
}


// MARK: - MoodSummaryView
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

// MARK: - RingPercentView (單一可重用)
struct RingPercentView: View {
    var progress: Double          // 0‥1
    var size: CGFloat             // 直徑

    private var lineWidth: CGFloat { size * 0.12 }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue,
                        style: StrokeStyle(lineWidth: lineWidth,
                                           lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(String(format: "%.0f%%", progress * 100))
                .font(size < 60 ? .caption2 : .headline)
                .bold()
        }
        .frame(width: size, height: size)
    }
}


// MARK: - SimpleGoalRow
struct SimpleGoalRow: View {
    var goal: Goal

    // 取全部日記
    @Query private var allEntries: [DiaryEntry]
    private var linkCount: Int {
        allEntries.filter { $0.goal?.id == goal.id }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 12) {
                RingPercentView(progress: goal.progress, size: 60)          // ← 左側進度環
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title).font(.headline)
                    if goal.kind == .target, let due = goal.targetDate {
                        let day = DateHelper.remainingDays(to: due)
                        Text(day >= 0 ? "剩 \(day) 天" : "已超過 \(abs(day)) 天")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    if !goal.detail.isEmpty {
                        Text(goal.detail).lineLimit(1).font(.caption)
                    }
                    Text("關聯日記：\(linkCount) 筆").font(.caption2)
                }
                Spacer()
            }
        }
    }
}

// MARK: - GoalRingView (首頁小卡使用)
struct GoalRingView: View {
    var goal: Goal

    private var subtitle: String {
        if goal.kind == .dream { return "夢想" }
        else if let due = goal.targetDate {
            let day = DateHelper.remainingDays(to: due)
            return day >= 0 ? "剩 \(day) 天" : "超 \(abs(day)) 天"
        } else { return "目標" }
    }

    var body: some View {
        VStack(spacing: 6) {
            RingPercentView(progress: goal.progress, size: 80)   // ★ 圓環加百分比
            Text(goal.title).font(.caption).multilineTextAlignment(.center).lineLimit(1)
            Text(subtitle).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(width: 90)
    }
}
