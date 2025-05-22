//
//  CountdownView.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import SwiftUI
import SwiftData

struct CountdownView: View {
    // 讀取所有 Goal
    @Query private var goals: [Goal]

    // 只要有 targetDate 的目標
    private var datedGoals: [Goal] {
        goals.filter { $0.targetDate != nil }
    }

    var body: some View {
        NavigationStack {
            List {
                // ① 明確給 id: \.id（UUID）
                ForEach(datedGoals, id: \.id) { goal in
                    if let due = goal.targetDate {
                        // ② 進度計算：已過百分比
                        let remaining = max(0, due.timeIntervalSinceNow)
                        let total     = max(1, due.timeIntervalSince(goal.createdAt))
                        let ratio     = 1.0 - remaining / total      // 0‥1

                        HStack {
                            ProgressRingView(progress: ratio)
                                .frame(width: 60, height: 60)

                            VStack(alignment: .leading) {
                                Text(goal.title)
                                    .font(.headline)

                                Text("剩餘 \(DateHelper.remainingDays(to: due)) 天")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("倒數")
        }
    }
}
