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
    @Bindable var entry: DiaryEntry
    @State private var editing = false
    @State private var picked: [PhotosPickerItem] = []


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
                TextEditor(text: $entry.text).frame(height: 120)
                PhotosPicker(selection: $picked,
                             maxSelectionCount: 12,
                             matching: .images) {
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
                VStack(alignment:.leading,spacing:8){
                    HStack{
                        Text(entry.title).font(.title2).bold()
                        Spacer()
                        MoodIconView(score: entry.moodScore)
                    }
                    Text(DateHelper.dateString(entry.date)).foregroundStyle(.secondary)
                    Text(entry.text).padding(.top,4)
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
            Button(editing ? "完成" : "編輯") {
                if editing { try? context.save() }
                editing.toggle()
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
