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
                GrowthGridView(entries: entries)
                    .padding(.bottom, 8)

                // 統計
                let cal = Calendar.current
                let totalYear = entries.count
                let totalMonth = entries.filter { cal.isDate($0.date, equalTo: Date(), toGranularity: .month) }.count
                let totalWeek  = entries.filter { cal.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }.count
                let finishedGoals = goals.filter { $0.progress >= 1 }
                let yearGoals = finishedGoals.filter {
                    if let due = $0.targetDate {
                        return cal.isDate(due, equalTo: Date(), toGranularity: .year)
                    }
                    return false
                }.count
                let monthGoals = finishedGoals.filter {
                    if let due = $0.targetDate {
                        return cal.isDate(due, equalTo: Date(), toGranularity: .month)
                    }
                    return false
                }.count
                let weekGoals = finishedGoals.filter {
                    if let due = $0.targetDate {
                        return cal.isDate(due, equalTo: Date(), toGranularity: .weekOfYear)
                    }
                    return false
                }.count

                HStack(spacing: 24) {
                    Label("今年紀錄 \(totalYear)", systemImage: "calendar")
                    Label("本月紀錄 \(totalMonth)", systemImage: "calendar.badge.clock")
                    Label("本週紀錄 \(totalWeek)", systemImage: "clock")
                }
                .font(.subheadline)
                .padding(.bottom, 8)

                HStack(spacing: 24) {
                    Label("今年完成目標 \(yearGoals)", systemImage: "flag.checkered")
                    Label("本月完成目標 \(monthGoals)", systemImage: "flag")
                    Label("本週完成目標 \(weekGoals)", systemImage: "bolt")
                }
                .font(.subheadline)
                .padding(.bottom, 16)

                // 隨機兩篇本週日記
                let weekEntries = entries.filter { cal.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }
                let randomWeek = Array(weekEntries.shuffled().prefix(1))
                if !randomWeek.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        NavigationLink {
                            List(weekEntries) { entry in
                                NavigationLink {
                                    DiaryDetailView(entry: entry)
                                } label: {
                                    JournalCardView(entry: entry)
                                }
                            }
                            .navigationTitle("本週日記列表")
                        } label: {
                            Text("本週回顧").font(.headline)
                        }
                        .padding(.vertical, 4)
                        .foregroundColor(.primary)
                        
                        ForEach(randomWeek) { entry in
                            NavigationLink {
                                DiaryDetailView(entry: entry)
                            } label: {
                                JournalCardView(entry: entry)
                            }
                        }
                        // 隨機一個本週完成目標
                        let weekFinishedGoals = finishedGoals.filter {
                            if let due = $0.targetDate {
                                return cal.isDate(due, equalTo: Date(), toGranularity: .weekOfYear)
                            }
                            return false
                        }
                        
                        if let randomWeekGoal = weekFinishedGoals.shuffled().first {
                            VStack(alignment: .leading, spacing: 6) {
                                
                                NavigationLink {
                                    List(weekFinishedGoals) { goal in
                                        NavigationLink {
                                            GoalDetailView(goal: goal)
                                        } label: {
                                            SimpleGoalRow(goal: goal)
                                        }
                                    }
                                    .navigationTitle("本週完成目標列表")
                                } label: {
                                    Text("本週完成目標回顧").font(.headline)
                                }
                                .padding(.vertical, 4)
                                .foregroundColor(.primary)

                                
                                VStack(alignment: .leading, spacing: 6) {
                                    NavigationLink { GoalDetailView(goal: randomWeekGoal) } label: {
                                        SimpleGoalRow(goal: randomWeekGoal)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // 隨機兩篇本月日記
                let monthEntries = entries.filter { cal.isDate($0.date, equalTo: Date(), toGranularity: .month) }
                let randomMonth = Array(monthEntries.shuffled().prefix(1))
                if !randomMonth.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        NavigationLink {
                            List(monthEntries) { entry in
                                NavigationLink {
                                    DiaryDetailView(entry: entry)
                                } label: {
                                    JournalCardView(entry: entry)
                                }
                            }
                            .navigationTitle("本月日記列表")
                        } label: {
                            Text("本月回顧").font(.headline)
                        }
                        .padding(.vertical, 4)
                        .foregroundColor(.primary)

                    
                        ForEach(randomMonth) { entry in
                            NavigationLink {
                                DiaryDetailView(entry: entry)
                            } label: {
                                JournalCardView(entry: entry)
                            }
                        }
                        // 隨機一個本月完成目標
                        let monthFinishedGoals = finishedGoals.filter {
                            if let due = $0.targetDate {
                                return cal.isDate(due, equalTo: Date(), toGranularity: .month)
                            }
                            return false
                        }
                        if let randomMonthGoal = monthFinishedGoals.shuffled().first {
                            NavigationLink {
                                List(monthFinishedGoals) { goal in
                                    NavigationLink {
                                        GoalDetailView(goal: goal)
                                    } label: {
                                        SimpleGoalRow(goal: goal)
                                    }
                                }
                                .navigationTitle("本月完成目標列表")
                            } label: {
                                Text("本月完成目標回顧").font(.headline)
                            }
                            .padding(.vertical, 4)
                            .foregroundColor(.primary)

                
                            VStack(alignment: .leading, spacing: 6) {
                                NavigationLink { GoalDetailView(goal: randomMonthGoal) } label: {
                                    SimpleGoalRow(goal: randomMonthGoal)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // 一年前的今天
                if let lastDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) {
                    let target = DateHelper.onlyDate(lastDate)
                    let lastYearEntries = entries.filter { DateHelper.onlyDate($0.date) == target }
                    
                    if let randomYearAgo = lastYearEntries.shuffled().first {
                        VStack(alignment: .leading, spacing: 6) {
                            NavigationLink {
                                List(lastYearEntries) { entry in
                                    NavigationLink {
                                        DiaryDetailView(entry: entry)
                                    } label: {
                                        JournalCardView(entry: entry)
                                    }
                                }
                                .navigationTitle("一年前日記列表")
                            } label: {
                                Text("一年前的今天").font(.headline)
                            }
                            .padding(.vertical, 4)
                            .foregroundColor(.primary)

                            
                            VStack(alignment: .leading, spacing: 6) {
                                NavigationLink { DiaryDetailView(entry: randomYearAgo) } label: {
                                    JournalCardView(entry: randomYearAgo)
                                }
                            }
                        }.padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("成長回顧")
        }
    }
    
    private func longestOneYearAgo() -> DiaryEntry? {
        guard let date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) else { return nil }
        let target = DateHelper.onlyDate(date)
        return entries
            .filter { DateHelper.onlyDate($0.date) == target }
            .max(by: { $0.text.count < $1.text.count })
    }
}
