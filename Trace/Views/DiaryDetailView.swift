//
//  DiaryDetailView.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import SwiftUI
import SwiftData

struct DiaryDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var entry: DiaryEntry
    @State private var editing = false

    var body: some View {
        Form {
            if editing {
                TextField("標題", text: $entry.title)
                DatePicker("日期", selection: $entry.date, displayedComponents: .date)
                Picker("心情", selection: $entry.moodScore) {
                    ForEach(1...5, id: \.self) { v in Text(String(v)).tag(v) }
                }.pickerStyle(.segmented)
                TextEditor(text: $entry.text).frame(height: 120)
            } else {
                VStack(alignment:.leading,spacing:8){
                    HStack{
                        Text(entry.title).font(.title2).bold()
                        Spacer()
                        MoodIconView(score: entry.moodScore)
                    }
                    Text(DateHelper.dateString(entry.date)).foregroundStyle(.secondary)
                    Text(entry.text).padding(.top,4)
                }
            }
        }
        .navigationTitle("日記")
        .toolbar {
            Button(editing ? "完成" : "編輯") {
                if editing { try? context.save() }
                editing.toggle()
            }
        }
    }
}
