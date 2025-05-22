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
            List {
                ForEach(goals) { goal in
                    GoalCardView(goal: goal)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                context.delete(goal)
                            } label: { Label("刪除", systemImage: "trash") }
                        }
                }
            }
            .navigationTitle("目標")
            .toolbar {
                Button { showAdd = true } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAdd) {
                AddGoalView()
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
                    Slider(value: $progress, in: 0...1) {
                        Text("進度")
                    }
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
