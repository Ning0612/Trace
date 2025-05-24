//
//  ReviewView.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import SwiftUI
import SwiftData

struct ReviewView: View {
    @Query private var entries: [DiaryEntry]
    @Query private var goals: [Goal]


    private var counts: [Date: Int] {
        Dictionary(grouping: entries) { DateHelper.onlyDate($0.date) }
            .mapValues { $0.count }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                GrowthGridView(entries: entries).padding(.bottom, 8)

                
                // 今年、本月、本週 線上統計
                let cal = Calendar.current
                let totalYear = entries.count
                let totalMonth = entries.filter { cal.isDate($0.date, equalTo: Date(), toGranularity: .month) }.count
                let totalWeek  = entries.filter { cal.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }.count

                HStack(spacing: 24) {
                    Label("今年紀錄 \(totalYear)", systemImage: "calendar")
                    Label("本月紀錄 \(totalMonth)", systemImage: "calendar.badge.clock")
                    Label("本週紀錄 \(totalWeek)", systemImage: "clock")
                }
                .font(.subheadline)
                .padding(.bottom, 8)
                
                let finishedGoals = goals.filter { $0.progress >= 1 }

                // 今年完成：targetDate 在今年
                let yearGoals = finishedGoals.filter {
                    if let due = $0.targetDate {
                        return cal.isDate(due, equalTo: Date(), toGranularity: .year)
                    }
                    return false
                }.count

                // 本月完成：targetDate 在本月
                let monthGoals = finishedGoals.filter {
                    if let due = $0.targetDate {
                        return cal.isDate(due, equalTo: Date(), toGranularity: .month)
                    }
                    return false
                }.count

                // 本週完成：targetDate 在本週
                let weekGoals = finishedGoals.filter {
                    if let due = $0.targetDate {
                        return cal.isDate(due, equalTo: Date(), toGranularity: .weekOfYear)
                    }
                    return false
                }.count

                HStack(spacing: 24) {
                    Label("今年完成目標 \(yearGoals)", systemImage: "flag.checkered")
                    Label("本月完成目標 \(monthGoals)", systemImage: "flag")
                    Label("本週完成目標 \(weekGoals)", systemImage: "bolt")
                }
                .font(.subheadline)
                .padding(.bottom, 8)

            }
            .navigationTitle("成長回顧")
        }
    }
    
    private func longest(of component: Calendar.Component) -> DiaryEntry? {
        let cal = Calendar.current
        let group = entries.filter { cal.isDate($0.date, equalTo: Date(), toGranularity: component) }
        return group.max(by: { $0.text.count < $1.text.count })
    }

    private func longestOneYearAgo() -> DiaryEntry? {
        guard let date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) else { return nil }
        let target = DateHelper.onlyDate(date)
        return entries
            .filter { DateHelper.onlyDate($0.date) == target }
            .max(by: { $0.text.count < $1.text.count })
    }

    private struct DiarySnippet: View {
        var title: String
        @Bindable var entry: DiaryEntry
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline)
                NavigationLink { DiaryDetailView(entry: entry) } label: {
                    JournalCardView(entry: entry)     // 直接沿用簡易卡片
                }
            }
            .padding(.vertical, 4)
        }
    }
}
