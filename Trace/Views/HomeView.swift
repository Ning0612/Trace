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
                    // Progress 百分比計算範例（HomeView 內）
                    if let nearest = goals.filter({ $0.targetDate != nil })
                                          .sorted(by: { $0.targetDate! < $1.targetDate! })
                                          .first,
                       let d = nearest.targetDate {

                        let remaining = max(0, d.timeIntervalSinceNow)
                        let total     = max(1, d.timeIntervalSince(nearest.createdAt))
                        let ratio     = 1.0 - remaining / total

                        ProgressRingView(progress: ratio)
                            .frame(width: 120, height: 120)
                            .padding(.bottom, 8)
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
