//
//  HomeView.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \DiaryEntry.date, order: .reverse, animation: .default)
    private var entries: [DiaryEntry]

    @Query(sort: \Goal.createdAt, order: .reverse, animation: .default)
    private var goals: [Goal]

    @State private var isAddingEntry = false
    @State private var isAddingGoal = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 取一個未完成 dream
                    
                    // 1. 未完成夢想，依進度排序取 3
                    let topDreams = goals
                        .filter { $0.kind == .dream && $0.progress < 1 }
                        .sorted { $0.progress > $1.progress }
                        //.prefix(3)

                    // 2. 未完成目標，依截止日最近取 3
                    let topTargets = goals
                        .filter { $0.kind == .target && $0.progress < 1 && $0.targetDate != nil }
                        .sorted { $0.targetDate! < $1.targetDate! }
                        //.prefix(3)

                    let topGoals = Array(topDreams) + Array(topTargets)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(topGoals, id: \.id) { g in
                                NavigationLink {
                                    GoalDetailView(goal: g)          // 目標／夢想詳細頁
                                } label: {
                                    GoalRingView(goal: g)            // 圓環小卡
                                }
                                .buttonStyle(.plain)                 // 取消預設藍色高亮
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // ① 先計算今天的日記數
                    let cal = Calendar.current
                    let todayCount = entries.filter { cal.isDate($0.date, inSameDayAs: Date()) }.count

                    // ② 在畫面中加入統計顯示（放在最新日記標題之前）
                    HStack {
                        Image(systemName: "book.closed")          // 小圖示
                        Text("今日日記：\(todayCount) 筆")
                            .font(.headline)
                    }
                    .padding(.vertical, 4)

                    // 快速新增
                    HStack{
                        Button(action: {
                            isAddingEntry.toggle()
                        }) {
                            Label("快速新增日記", systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .sheet(isPresented: $isAddingEntry) {
                            AddEntryView()
                        }
                        
                        Button(action: {
                            isAddingGoal.toggle()
                        }) {
                            Label("快速新增目標", systemImage: "target")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .sheet(isPresented: $isAddingGoal) {
                            AddGoalView()
                        }
                    }
                    
                    // 1. 即將到期的目標（7 天內）
                    let upcomingGoals = goals
                        .filter { $0.progress < 1 && $0.targetDate != nil }
                        .filter { goal in
                            let days = cal.dateComponents([.day], from: Date(), to: goal.targetDate!).day ?? 0
                            return days >= 0 && days <= 7
                        }
                    if !upcomingGoals.isEmpty {
                        SectionHeader("即將到期目標")
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(upcomingGoals) { g in
                                NavigationLink {
                                    GoalDetailView(goal: g)
                                } label: {
                                    SimpleGoalRow(goal: g)
                                }
                            }
                        }
                    }

                    // 2. 久未更新的目標（尚未完成，30 天未更新，隨機一筆）
                    let staleThreshold = cal.date(byAdding: .day, value: -30, to: Date())!
                    let staleGoals = goals.filter { goal in
                        guard goal.progress < 1 else { return false }
                        let relatedEntries = entries.filter { $0.goal?.id == goal.id }
                        guard let lastDate = relatedEntries.map({ $0.date }).max() else { return false }
                        return lastDate < staleThreshold
                    }
                    if let randomStale = staleGoals.shuffled().first {
                        SectionHeader("久未更新目標")
                        NavigationLink {
                            // 列出所有久未更新目標或直接跳至該目標？
                            List([randomStale]) { g in
                                NavigationLink {
                                    GoalDetailView(goal: g)
                                } label: {
                                    SimpleGoalRow(goal: g)
                                }
                            }
                            .navigationTitle("久未更新目標列表")
                        } label: {
                            SimpleGoalRow(goal: randomStale)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                        }
                    }

                    // 最新三篇
                    if !entries.isEmpty {
                        SectionHeader("最新日記")
                        VStack(alignment: .leading){
                            ForEach(entries.prefix(3)) { e in
                                NavigationLink { DiaryDetailView(entry: e) } label: {
                                    JournalCardView(entry: e)
                                }
                            }
                        }
                    }

                }
                .padding()
            }
            .navigationTitle("Trace")
        }
    }
}
