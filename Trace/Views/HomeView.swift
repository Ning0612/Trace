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

    @State private var showAdd = false



    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
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



                    // 最新三篇
                    if !entries.isEmpty {
                        SectionHeader("最新日記")
                        ForEach(entries.prefix(3)) { e in
                            NavigationLink { DiaryDetailView(entry: e) } label: {
                                JournalCardView(entry: e)
                            }
                        }
                    }

                    // 快速新增
                    Button {
                        // 可導向 Journal 新增
                        showAdd = true 
                    } label: {
                        Label("快速新增日記", systemImage: "plus.circle")
                            .font(.title3)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Trace")
        }.toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showAdd = true          // ← 開啟 sheet
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            AddEntryView()
        }
    }
}
