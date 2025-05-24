// GrowthGridView.swift
// Trace — 點擊格子查看當日日記

import SwiftUI

struct GrowthGridView: View {
    var entries: [DiaryEntry]

    // 原本的常數／屬性
    private let cell : CGFloat = 11
    private let gap  : CGFloat = 2
    private var colW: CGFloat { cell + gap }
    private var rowH: CGFloat { cell + gap }
    private let weekdayWidth: CGFloat = 28

    private let cal = Calendar.current

    // 取得所有年份（含今年）
    private var years: [Int] {
        let yearSet = Set(entries.map { cal.component(.year, from: $0.date) })
        let thisYear = cal.component(.year, from: Date())
        return Array(yearSet.union([thisYear])).sorted(by: >)
    }

    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())

    // 篩出當前年份的日記
    private var yearEntries: [DiaryEntry] {
        entries.filter { cal.component(.year, from: $0.date) == selectedYear }
    }

    // 每日計數
    private var counts: [Date: Int] {
        Dictionary(grouping: yearEntries) { DateHelper.onlyDate($0.date) }
            .mapValues { $0.count }
    }

    // 該年第一個 Sunday 做起點
    private var firstSunday: Date {
        let jan1 = cal.date(from: DateComponents(year: selectedYear, month: 1, day: 1))!
        let comp  = DateComponents(weekday: 1)
        return cal.nextDate(
            after: jan1,
            matching: comp,
            matchingPolicy: .nextTime,
            direction: .backward
        )!
    }

    // 1 月第一天應落在哪一週（欄位）── 给 colIdxZero
    private var colIdxZero: Int {
        let dt = cal.date(from: DateComponents(year: selectedYear, month: 1, day: 1))!
        let daysDiff = cal.dateComponents([.day], from: firstSunday, to: dt).day ?? 0
        return max(0, daysDiff / 7)
    }

    // 著色邏輯（不變）
    private func color(for c: Int) -> Color {
        switch c {
        case 0:  return .black
        case 1:  return Color.green.opacity(0.25)
        case 2:  return Color.green.opacity(0.45)
        case 3:  return Color.green.opacity(0.65)
        case 4:  return Color.green.opacity(0.8)
        default: return Color.green.opacity(0.95)
        }
    }

    // 取得某天所有日記
    private func entries(on date: Date) -> [DiaryEntry] {
        yearEntries.filter { DateHelper.onlyDate($0.date) == DateHelper.onlyDate(date) }
    }

    var body: some View {
        HStack(spacing: gap) {

            // 左側：Mon / Wed / Fri
            VStack(alignment: .leading, spacing: rowH) {
                Color.clear.frame(height: 3) // Sun 佔位
                Text("Mon").font(.caption2)
                Text("Wed").font(.caption2)
                Text("Fri").font(.caption2)
            }
            .frame(width: weekdayWidth, alignment: .leading)
            .foregroundStyle(.secondary)

            // 中央：可滑動區（月份列＋格子）
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: gap) {

                    // 月份列（不變，只留空位到第一個月）
                    ZStack(alignment: .topLeading) {
                        ForEach(1...12, id: \.self) { m in
                            if let monthStart = cal.date(from: DateComponents(year: selectedYear, month: m, day: 1)) {
                                let daysDiff = cal.dateComponents(
                                    [.day],
                                    from: firstSunday,
                                    to: monthStart
                                ).day ?? 0
                                let colIdx = max(0, daysDiff / 7)
                                // 不要再加 weekdayWidth
                                let xOffset = CGFloat(colIdx) * colW

                                Text(cal.shortMonthSymbols[m-1].prefix(3))
                                    .font(.caption2)
                                    // 改成 offset，比 position 更直覺
                                    .offset(x: xOffset, y: 0)
                            }
                        }
                    }
                    // 修改後至少要保留足夠高度
                    .frame(height: cell)
                    .padding(.top, gap)

                    // 格子區：7 行 × 53 週
                    HStack(spacing: gap) {
                        ForEach(0..<53, id: \.self) { col in
                            VStack(spacing: gap) {
                                ForEach(0..<7, id: \.self) { row in
                                    let maybeDay = cal.date(
                                        byAdding: .day,
                                        value: col * 7 + row,
                                        to: firstSunday
                                    )
                                    if let day = maybeDay,
                                       cal.component(.year, from: day) == selectedYear {
                                        // ★ 在這裡把原先的 Rectangle 用 NavigationLink 包起來
                                        NavigationLink {
                                            // 目的頁：顯示該日所有日記
                                            DayEntriesView(
                                                date: day,
                                                entries: entries(on: day)
                                            )
                                        } label: {
                                            Rectangle()
                                                .fill(color(for: counts[day, default: 0]))
                                                .frame(width: cell, height: cell)
                                                .overlay(
                                                    Rectangle()
                                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                        }
                                        .buttonStyle(.plain) // 去除藍色框
                                    } else {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width: cell, height: cell)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.leading, 0)
            }
            .frame(height: rowH * 8) // 1 行月 + 7 行

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(years, id: \.self) { y in
                        Text(String(y))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(selectedYear == y ? Color.blue : Color.clear)
                            .cornerRadius(6)
                            .foregroundColor(selectedYear == y ? .white : .primary)
                            .onTapGesture { selectedYear = y }
                    }
                }
                .padding(.vertical, gap)        // 兩端留一點空隙
            }
            // 高度跟主圖表一樣，讓超出的部分可滾動
            .frame(height: rowH * 7 + 30)
        }
    }
}

// 新增這個子畫面：點格子後跳到這裡，顯示該天的日記列表
struct DayEntriesView: View {
    let date: Date
    let entries: [DiaryEntry]

    var body: some View {
        List {
            ForEach(entries) { entry in
                NavigationLink {
                    DiaryDetailView(entry: entry)
                } label: {
                    JournalCardView(entry: entry)
                }
            }
        }
        .navigationTitle(DateHelper.dateString(date))
    }
}
