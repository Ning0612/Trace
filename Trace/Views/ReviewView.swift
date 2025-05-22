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

    // 按今年 365 生成統計
    private var countsByDate: [Date: Int] {
        Dictionary(grouping: entries) { DateHelper.onlyDate($0.date) }
            .mapValues { $0.count }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                YearHeatmapView(countsByDate: countsByDate)
                    .padding()
                MoodSummaryView(entries: entries)      // ← 新增
                        .padding(.horizontal)
            }
            .navigationTitle("成長回顧")
        }
    }
}
