import SwiftUI

// MARK: - GrowthGridView
struct GrowthGridView: View {
    var entries: [DiaryEntry]
    
    private let cell : CGFloat = 11
    private let gap  : CGFloat = 2
    private var colW: CGFloat { cell + gap }
    private var rowH: CGFloat { cell + gap}
    private let weekdayWidth: CGFloat = 28   // 給星期文字的固定寬


    // 取得所有出現過的年份（含今年），由大到小排列
    private var years: [Int] {
        let yearSet = Set(entries.map { Calendar.current.component(.year, from: $0.date) })
        let thisYear = Calendar.current.component(.year, from: Date())
        return Array(yearSet.union([thisYear])).sorted(by: >)
    }

    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())

    // 該年所有日記
    private var yearEntries: [DiaryEntry] {
        entries.filter { Calendar.current.component(.year, from: $0.date) == selectedYear }
    }

    // 當年每日計數
    private var counts: [Date: Int] {
        Dictionary(grouping: yearEntries) { DateHelper.onlyDate($0.date) }
            .mapValues { $0.count }
    }

    private let cal = Calendar.current
    private var firstSunday: Date {
        // 該年 1/1
        let jan1 = cal.date(from: DateComponents(year: selectedYear, month: 1, day: 1))!
        // 目標條件：weekday = 1 (Sunday)
        let comp  = DateComponents(weekday: 1)

        return cal.nextDate(after: jan1,
                            matching: comp,
                            matchingPolicy: .nextTime,
                            direction: .backward)!
    }

    private var allDays: [Date] {
        // 53 週 × 7 = 371，足夠囊括閏年
        (0..<371).compactMap { cal.date(byAdding: .day, value: $0, to: firstSunday) }
            .filter { cal.component(.year, from: $0) == selectedYear }
    }

    // 顏色邏輯
    private func color(for c: Int) -> Color {
        switch c {
        case 0:  return .black
        case 1:  return Color.green.opacity(0.25)
        case 2:  return Color.green.opacity(0.45)
        case 3:  return Color.green.opacity(0.65)
        case 4:  return Color.green.opacity(0.8)
        default: return Color.green.opacity(0.95)
        }
    }

    var body: some View {
        HStack(spacing: gap) {

            // --- 左側星期列 (Mon Wed Fri) ---
            VStack(alignment: .leading, spacing: rowH) {
                Color.clear.frame(height: 3)      // Sun 行佔位
                Text("Mon").font(.caption2)
                Text("Wed").font(.caption2)
                Text("Fri").font(.caption2)
            }
            .frame(width: weekdayWidth, alignment: .leading)
            .foregroundStyle(.secondary)


            // --- 右側可滑動內容 (月份列 + 貢獻格) ---
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: gap) {

                    ZStack(alignment: .topLeading) {
                        ForEach(1...12, id: \.self) { m in
                            if let monthStart = cal.date(from: DateComponents(year: selectedYear, month: m, day: 1)) {
                                let daysDiff = cal.dateComponents(
                                    [.day],
                                    from: firstSunday,
                                    to: monthStart
                                ).day ?? 0
                                let colIdx = max(0, daysDiff / 7)
                                // 不要再加 weekdayWidth
                                let xOffset = CGFloat(colIdx) * colW

                                Text(cal.shortMonthSymbols[m-1].prefix(3))
                                    .font(.caption2)
                                    // 改成 offset，比 position 更直覺
                                    .offset(x: xOffset, y: 0)
                            }
                        }
                    }
                    // 修改後至少要保留足夠高度
                    .frame(height: cell)
                    .padding(.top, gap)



                    // 2-B 貢獻格 7 行（Sun~Sat）
                    HStack(spacing: gap) {
                        ForEach(0..<53, id: \.self) { col in
                            VStack(spacing: gap) {
                                ForEach(0..<7, id: \.self) { row in
                                    if let day = cal.date(byAdding: .day, value: col*7 + row, to: firstSunday),
                                       cal.component(.year, from: day) == selectedYear {
                                        Rectangle()
                                            .fill(color(for: counts[day, default: 0]))
                                            .frame(width: cell, height: cell)
                                            .overlay(
                                                Rectangle()
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    } else {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width: cell, height: cell)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.leading, 0)             // Scroll 區內不再需要額外 left padding
            }
            .frame(height: rowH * 7 + 30)              // 7 行高度
            
            // 放在外層 HStack 右邊，改成可垂直滾動
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(years, id: \.self) { y in
                        Text(String(y))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(selectedYear == y ? Color.blue : Color.clear)
                            .cornerRadius(6)
                            .foregroundColor(selectedYear == y ? .white : .primary)
                            .onTapGesture { selectedYear = y }
                    }
                }
                .padding(.vertical, gap)        // 兩端留一點空隙
            }
            // 高度跟主圖表一樣，讓超出的部分可滾動
            .frame(height: rowH * 7 + 30)
        }
    }
}
