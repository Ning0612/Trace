//
//  DiaryEntry.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import Foundation
import SwiftData

@Model
final class DiaryEntry {
    var date: Date
    var text: String
    var moodScore: Int        // 1‒5
    var imageDatas: [Data] = []
    var title: String
    var goal: Goal?          // 選填：關聯目標 / 夢想

    // 🔍 在 init 參數列第一個位置加上 title
    init(title: String,
         date: Date = .now,
         text: String = "",
         moodScore: Int = 3,
         imageDatas: [Data] = [],
         goal: Goal? = nil) {
        self.title = title
        self.date = date
        self.text = text
        self.moodScore = moodScore
        self.imageDatas = imageDatas
        self.goal = goal
    }
}
