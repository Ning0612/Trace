//
//  JournalView.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import SwiftUI
import SwiftData
import PhotosUI

struct JournalView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \DiaryEntry.date, order: .reverse, animation: .default)
    private var entries: [DiaryEntry]
    
    @State private var showAdd = false
    @State private var pendingDiary: DiaryEntry?
    @State private var confirmDiary = false


    var body: some View {
        NavigationStack {
            List {
                ForEach(entries) { entry in
                    NavigationLink { DiaryDetailView(entry: entry) } label: {
                        JournalCardView(entry: entry)
                    }
                }
                .onDelete { idx in
                    pendingDiary = entries[idx.first!]
                    confirmDiary = true
                }
            }
            .navigationTitle("日記")
            .toolbar {
                Button { showAdd = true } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAdd) {
                AddEntryView()
            }
            .alert("確定要刪除？", isPresented: $confirmDiary, presenting: pendingDiary) { d in
                Button("刪除", role: .destructive) { context.delete(d); try? context.save() }
                Button("取消", role: .cancel) { }
            } message: { _ in Text("刪除後無法復原") }
        }
    }
}

// MARK: - AddEntryView
struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var date = Date()
    @State private var text = ""
    @State private var title = ""
    @State private var mood = 3
    @State private var selectedGoal: Goal?
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var imageDatas: [Data] = []   // ← 陣列

    
    @Query var allGoals: [Goal]

    var body: some View {
        NavigationStack {
            Form {
                Section("心情") {
                    Picker("心情", selection: $mood) {
                        ForEach(1...5, id: \.self) { v in
                            Text(emoji(for: v))   // 顯示 emoji 而非數字
                                .tag(v)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("標題") {
                    TextField("輸入標題", text: $title)
                }
                
                Section("關聯目標") {
                    Menu {
                        // 以搜尋欄形式列出全部目標／夢想
                        ForEach(allGoals, id: \.id) { g in
                            Button(g.title) { selectedGoal = g }
                        }
                        if selectedGoal != nil {
                            Button(role: .destructive, action: { selectedGoal = nil }) {
                                Text("清除選擇")
                            }
                        }
                    } label: {
                        Text(selectedGoal?.title ?? "未選擇")
                            .foregroundStyle(selectedGoal == nil ? .secondary : .primary)
                    }
                }
                
                Section("日期") {
                    DatePicker("選擇日期", selection: $date, displayedComponents: .date)
                }

                Section("內容") {
                    TextEditor(text: $text)
                        .frame(height: 120)
                }

                
                Section("照片") {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 12,                // 任意上限
                        matching: .images
                    ) { Label("選擇照片", systemImage: "photo.on.rectangle") }

                    ScrollView(.horizontal) {                // 選取後預覽
                        HStack {
                            ForEach(imageDatas, id: \.self) { data in
                                if let img = UIImage(data: data) {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
                .onChange(of: selectedItems) { _, newItems in
                    Task {
                        imageDatas = []                      // 清空再加入
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                imageDatas.append(data)
                            }
                        }
                    }
                }
            }
            .navigationTitle("新增日記")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        let entry = DiaryEntry(title: title,
                                               date: date,
                                               text: text,
                                               moodScore: mood,
                                               imageDatas: imageDatas,   // ← 改這裡
                                               goal: selectedGoal)
                        context.insert(entry)
                        try? context.save()
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func emoji(for value: Int) -> String {
        switch value {
        case ..<2: "😢"
        case 2:    "😐"
        case 3:    "🙂"
        case 4:    "😊"
        default:   "😄"
        }
    }
}
