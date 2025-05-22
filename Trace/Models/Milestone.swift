//
//  Milestone.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import Foundation
import SwiftData

@Model
final class Milestone {
    var title: String
    var targetDate: Date
    var goal: Goal?

    init(title: String,
         targetDate: Date,
         goal: Goal? = nil) {
        self.title = title
        self.targetDate = targetDate
        self.goal = goal
    }
}
