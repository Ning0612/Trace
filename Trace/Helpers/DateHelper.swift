//
//  DateHelper.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import Foundation

enum DateHelper {
    static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_Hant_TW")
        f.dateStyle = .medium
        return f
    }()

    static func dateString(_ date: Date) -> String {
        formatter.string(from: date)
    }

    static func remainingDays(to date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: .now, to: date).day ?? 0
    }

    /// 去除時間的純日期
    static func onlyDate(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    /// convenience：距離的 double 秒
    static func distance(from start: Date, to end: Date) -> TimeInterval {
        end.timeIntervalSince(start)
    }
}
