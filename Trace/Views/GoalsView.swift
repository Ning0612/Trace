//
//  GoalsView.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var context
    @Query(animation: .default) private var goals: [Goal]

    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            // 預先切三類，減少型別推斷負擔
            let dreams      = goals.filter { $0.kind == .dream }
            // 尚未完成的目標 → 按「最近到期」由近到遠排序
            let inProgress = goals
                .filter { $0.kind == .target && $0.progress < 1 }
                .sorted {
                    // 取出非 nil 的 targetDate，再由小到大
                    ($0.targetDate ?? .distantFuture) < ($1.targetDate ?? .distantFuture)
                }

            // 已完成的目標 → 按「最接近今天的到期日」由近到遠排序
            let finished = goals
                .filter { $0.kind == .target && $0.progress >= 1 }
                .sorted {
                    let d0 = ($0.targetDate ?? .distantPast).timeIntervalSinceNow
                    let d1 = ($1.targetDate ?? .distantPast).timeIntervalSinceNow
                    return d0 > d1
                }

            List {
                Section("夢想")          { goalRows(dreams) }
                Section("進行中目標")    { goalRows(inProgress) }
                Section("已完成目標")    { goalRows(finished) }
            }
            .navigationTitle("目標")
            .toolbar {
                Button { showAdd = true } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $showAdd) { AddGoalView() }
        }
    }

    /// 產生可刪除列（直接刪除）
    @ViewBuilder
    private func goalRows(_ source: [Goal]) -> some View {
        ForEach(source, id: \.id) { g in
            NavigationLink { GoalDetailView(goal: g) } label: {
                SimpleGoalRow(goal: g)
            }
        }
        .onDelete { idxSet in
            for index in idxSet {
                let goal = source[index]
                do {
                    let linkedEntries = try context.fetch(FetchDescriptor<DiaryEntry>())
                    for entry in linkedEntries.filter({ $0.goal?.id == goal.id }) {
                        entry.goal = nil
                    }
                    context.delete(goal)
                    try context.save()
                } catch {
                    print("❌ 刪除目標時發生錯誤：\(error)")
                }
            }
        }
    }
}



// MARK: - AddGoalView
struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var title = ""
    @State private var detail = ""
    @State private var kind: GoalKind = .target
    @State private var targetDate = Date()
    @State private var progress = 0.0

    var body: some View {
        NavigationStack {
            Form {
                TextField("標題", text: $title)
                TextField("描述", text: $detail)

                Picker("類型", selection: $kind) {
                    ForEach(GoalKind.allCases) { k in
                        Text(k == .dream ? "夢想" : "目標").tag(k)
                    }
                }
                .pickerStyle(.segmented)

                if kind == .target {
                    DatePicker("截止日期", selection: $targetDate, displayedComponents: .date)
                }
                
                HStack {
                    Text("進度 : \(Int(progress * 100))%")
                    Spacer()
                    Slider(value: $progress, in: 0...1)
                }
            }
            .navigationTitle("新增目標")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        context.insert(
                            Goal(title: title,
                                 detail: detail,
                                 kind: kind,
                                 targetDate: kind == .target ? targetDate : nil,
                                 progress: progress)
                        )
                        try? context.save()
                        dismiss()
                    }.disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
