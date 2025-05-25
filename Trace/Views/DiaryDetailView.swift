//
//  DiaryDetailView.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import SwiftUI
import SwiftData
import PhotosUI

struct DiaryDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var entry: DiaryEntry
    @State private var editing = false
    @State private var picked: [PhotosPickerItem] = []
    @State private var showDeleteConfirm = false

    var body: some View {
        Form {
            if editing {
                TextField("標題", text: $entry.title)
                DatePicker("日期", selection: $entry.date, displayedComponents: .date)
                Picker("心情", selection: $entry.moodScore) {
                    ForEach(1...5, id: \.self) { v in
                        Text(emoji(for: v)).tag(v)
                    }
                }
                .pickerStyle(.segmented)

                TextEditor(text: $entry.text)
                    .frame(height: 120)

                PhotosPicker(
                    selection: $picked,
                    maxSelectionCount: 12,
                    matching: .images
                ) {
                    Label("重新選擇照片", systemImage: "photo")
                }
                .onChange(of: picked) { _, items in
                    Task {
                        entry.imageDatas = []
                        for it in items {
                            if let d = try? await it.loadTransferable(type: Data.self) {
                                entry.imageDatas.append(d)
                            }
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(entry.title)
                            .font(.title2).bold()
                        Spacer()
                        MoodIconView(score: entry.moodScore)
                    }
                    Text(DateHelper.dateString(entry.date))
                        .foregroundStyle(.secondary)
                    Text(entry.text)
                        .padding(.top, 4)
                    if !entry.imageDatas.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(entry.imageDatas, id: \.self) { data in
                                    if let ui = UIImage(data: data) {
                                        Image(uiImage: ui)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 180, height: 180)
                                            .clipped()
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("日記")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // 刪除按鈕
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                }
                // 編輯/完成 按鈕
                Button(editing ? "完成" : "編輯") {
                    if editing { try? context.save() }
                    editing.toggle()
                }
            }
        }
        .alert("確定要刪除這篇日記？", isPresented: $showDeleteConfirm) {
            Button("刪除", role: .destructive) {
                context.delete(entry)
                try? context.save()
                dismiss()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("刪除後無法復原")
        }
    }

    private func emoji(for value: Int) -> String {
        switch value {
        case ..<2: return "😢"
        case 2:    return "😐"
        case 3:    return "🙂"
        case 4:    return "😊"
        default:   return "😄"
        }
    }
}
