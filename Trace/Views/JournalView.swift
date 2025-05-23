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

    var body: some View {
        NavigationStack {
            List {
                ForEach(entries) { entry in
                    NavigationLink { DiaryDetailView(entry: entry) } label: {
                        JournalCardView(entry: entry)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        context.delete(entries[index])
                    }
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
    @State private var photo: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var selectedGoal: Goal?

    
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
                    PhotosPicker(selection: $photo, matching: .images) {
                        Label("選擇照片", systemImage: "photo")
                    }
                    if let data = imageData,
                       let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(8)
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
                                               imageData: imageData,
                                               goal: selectedGoal)
                        context.insert(entry)
                        try? context.save()
                        dismiss()
                    }.disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: photo) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
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
