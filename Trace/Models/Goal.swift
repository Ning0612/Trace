//
//  Goal.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import Foundation
import SwiftData

enum GoalKind: String, Codable, CaseIterable, Identifiable {
    case dream   // 抽象夢想
    case target  // 具體目標

    var id: Self { self }
}

@Model
final class Goal : Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var detail: String
    var kind: GoalKind
    var createdAt: Date
    var targetDate: Date?     // 若為 dream 可為 nil
    var progress: Double      // 0.0‒1.0
    var imageName: String?    // Assets 內圖示

    init(title: String,
         detail: String = "",
         kind: GoalKind = .target,
         targetDate: Date? = nil,
         progress: Double = 0.0,
         imageName: String? = nil,
         createdAt: Date = .now) {
        self.title = title
        self.detail = detail
        self.kind = kind
        self.targetDate = targetDate
        self.progress = progress
        self.imageName = imageName
        self.createdAt = createdAt
    }
}
