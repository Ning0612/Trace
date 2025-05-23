//
//  GoalDetailView.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var goal: Goal

    @State private var editing = false

    // entries 與 related 同前版
    @Query private var allEntries: [DiaryEntry]
    private var related: [DiaryEntry] {
        allEntries.filter { $0.goal?.id == goal.id }
    }
    init(goal: Goal) {
        self.goal = goal
        self._allEntries = Query(sort: \DiaryEntry.date, order: .reverse)
    }

    var body: some View {
        Form {
            Section {
                if editing {
                    TextField("標題", text: $goal.title)
                    TextEditor(text: $goal.detail).frame(height: 80)
                    if goal.kind == .target {
                        DatePicker(
                            "截止日期",
                            selection: Binding(
                                get: { goal.targetDate ?? Date() },
                                set: { goal.targetDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                    
                    HStack {
                        Text("進度 : \(Int(goal.progress * 100))%")
                        Spacer()
                        Slider(value: $goal.progress, in: 0...1)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(goal.title).font(.title2).bold()
                        if !goal.detail.isEmpty { Text(goal.detail) }
                        if let due = goal.targetDate {
                            Text("截止：\(DateHelper.dateString(due))")
                            Text("剩 \(DateHelper.remainingDays(to: due)) 天")
                        }
                        ProgressView(value: goal.progress)
                    }
                }
            }

            Section("關聯日記 \(related.count) 筆") {
                ForEach(related) { e in
                    NavigationLink { DiaryDetailView(entry: e) } label: {
                        Text(e.title)
                    }
                }
            }
        }
        .navigationTitle(goal.kind == .dream ? "夢想" : "目標")
        .toolbar {
            Button(editing ? "完成" : "編輯") {
                if editing { try? context.save() }
                editing.toggle()
            }
        }
    }
}

/// 工具：把 Optional Date 轉 Binding<Date>
extension Binding where Value == Date? {
    init(_ source: Binding<Date?>, replacingNilWith defaultDate: Date) {
        self.init(get: { source.wrappedValue ?? defaultDate },
                  set: { source.wrappedValue = $0 })
    }
}

