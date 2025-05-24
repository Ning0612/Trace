//
//  MockDataLoader .swift
//  Trace
//
//  Created by 王政甯 on 2025/5/25.
//

import SwiftData
import SwiftUI

func preloadMockDataIfNeeded(context: ModelContext) {
    guard let existing = try? context.fetch(FetchDescriptor<Goal>()), existing.isEmpty else { return }

    func date(_ str: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: str)!
    }

    func randomDate(before deadline: Date) -> Date {
        let offset = Int.random(in: -13...0)
        return Calendar.current.date(byAdding: .day, value: offset, to: deadline)!
    }

    func insertDiary(baseDate: Date, entries: [(String, String)], goal: Goal) {
        for (title, text) in entries {
            let diary = DiaryEntry(
                title: title,
                date: randomDate(before: baseDate),
                text: text,
                moodScore: Int.random(in: 2...5),
                goal: goal
            )
            context.insert(diary)
        }
    }

    // === 目標 ===
    let goals: [(String, String, Double, String, [(String, String)])] = [

        ("iOS Final Project Game", "2025-06-04", 1.0,
         "利用西瓜遊戲的玩法設計「CompBall」——將電腦組成元件一顆顆合成升級，從電晶體合成到整台電腦。不只是遊戲，也希望讓玩家邊玩邊理解資訊工程的核心概念。",
         [
            ("合成動畫完成", "CompBall 每次升級會加入光暈動畫，增加合成的爽感。"),
            ("ALU → CU 過程卡住", "邏輯閘太難分出哪些能合成，多工器還沒做出來。"),
            ("爆倉處理修好了", "設定邊界邏輯後，如果球出界會自動 trigger 結束，感覺完整多了。")
        ]),

        ("iOS Final Project APP", "2025-06-04", 0.5,
         "Trace 是一個幫助使用者記錄自己生活與成長的 App。從照片、文字、語音記錄當下，到追蹤目標與倒數天數，幫助使用者「看見自己一路走來的變化」。",
         [
            ("夢想牆畫面初步完成", "Trace App 目標區塊可以顯示倒數天數，看起來蠻療癒的。"),
            ("加入 SwiftData 模型錯誤", "container 沒初始化導致整個 app 崩潰，debug 半天才找到原因。"),
            ("一人做兩個專案真的爆炸", "Game 和 App 都還沒收尾，時間壓力快頂不住。")
        ]),

        ("Compiler Project 3 Code Generation", "2025-06-10", 0.0,
         "專案的最後階段，要把 AST 轉成中介碼甚至實際機器碼。這部分要處理 register 分配、block 結構與指令序列安排，是整個編譯器實作中最貼近「輸出程式碼」的一步。",
         [
            ("第一個 IR 模板", "試著產生 basic block，但 register 分配還沒搞懂。"),
            ("LLIR vs MIPS", "不知道要不要產生虛擬碼再轉 MIPS，還在看其他人的作法。"),
            ("進度嚴重落後", "完全沒動靜，快來不及了，可能要通宵。")
        ]),

        ("Compiler Project 2 Parser", "2025-05-20", 1.0,
         "根據文法製作語法分析器，實作 Predictive Parsing、左因子化與 LL(1) 分析。從原始 token 到語法樹，是實現語意之前不可或缺的一步。",
         [
            ("Predictive Parser 成功運作", "根據 LL(1) grammar 製作了 transition diagram，超級有成就感。"),
            ("Left Factoring 處理", "原本 grammar 有 ambiguity，左因子化後終於能跑。"),
            ("Derivation Tree 測試通過", "五筆測資都能產出正確 derivation tree，應該可以交了。")
        ]),

        ("Compiler Project 2 Scanner", "2025-04-17", 1.0,
         "用正規表示法描述語言語彙，建立掃描器以產生正確的 token。這是從文字到程式語意的第一道關卡，也讓我學會了怎麼精準分析字串結構。",
         [
            ("token 定義完成", "用正規表示法完成所有保留字與識別字的 match。"),
            ("Symbol table 串接", "掃描時能記錄變數與位置，之後 Parser 可直接用。"),
            ("測資全過", "從 test0.sd 到 test5.sd 都能完整掃描。")
        ]),

        ("Database System Final Exam", "2025-06-03", 0.6,
         "課程涵蓋 ER model、正規化、transaction control、SQL 查詢與資料庫設計。期末考內容量大但實用，挑戰在於每個觀念都牽涉到實際應用邏輯。",
         [
            ("Normalization 規則整理", "從 1NF 到 BCNF 畫成流程圖，稍微搞懂 dependency。"),
            ("Transaction 控制複習", "2PL、Serializability 還是有點模糊，多寫題目試試。"),
            ("SQL 聚合測驗", "COUNT + GROUP BY 的題目反而錯最多，要特別注意語法細節。")
        ]),

        ("Compiler Design Final Exam", "2025-06-03", 0.1,
         "包含 syntax analysis、SDD、translation scheme、error recovery 等核心主題。考試雖然理論多，但概念一通後回頭看整體流程會更清楚。",
         [
            ("Error Recovery 策略", "Panic mode 跟 Phrase level 看完了，但還沒搞懂 Error Production。"),
            ("LL vs LR 模型整理", "用圖表對照 Top-down 與 Bottom-up，會考的機率應該滿高。")
        ]),

        ("Coding Theory Final Exam", "2025-06-04", 0.1,
         "討論 finite field、Hamming code、cyclic code 與錯誤偵測技術。對我來說是最抽象的一門課，但也學到數學與通訊技術的交集。",
         [
            ("還是搞不懂 α", "Fq 裡的 α 感覺像符號代號，但整個抽象得很…"),
            ("Cyclic Code 原理看第三次", "x^n - 1 的除法與多項式模運算還是很陌生。")
        ])
    ]

    for (title, deadlineStr, progress, detail, entries) in goals {
        let deadline = date(deadlineStr)
        let goal = Goal(
            title: title,
            detail: detail,
            kind: .target,
            targetDate: deadline,
            progress: progress,
            imageName: "star"
        )
        context.insert(goal)
        insertDiary(baseDate: deadline, entries: entries, goal: goal)
    }

    // === 夢想 ===
    let dreams: [(String, String, [(String, String)])] = [
        ("做自己想做的事",
         "在壓力之中找到自己的節奏，用創作做出自己想用的產品、寫出真正想寫的文字，而不只是為了交作業或拿分數。",
         [
            ("創業點子筆記", "想到可以做開源日記工具，結合情緒分析與 tag 系統。"),
            ("試著當自己產品經理", "設計了一週的 app wireframe，想想就覺得興奮。")
         ]),
        ("保持健康",
         "程式人生也該有好體能。想建立早睡、運動、飲食控制的習慣，讓生活不只寫 code，也寫出健康。",
         [
            ("晚睡習慣改善 Day 1", "今天十二點前上床，早上起來精神好多了。"),
            ("日常活動記錄", "除了打 code，今天還去操場繞一圈，放空很好用。")
         ])
    ]

    for (title, detail, entries) in dreams {
        let goal = Goal(
            title: title,
            detail: detail,
            kind: .dream,
            progress: 0.3,
            imageName: "heart"
        )
        context.insert(goal)
        insertDiary(baseDate: date("2025-06-04"), entries: entries, goal: goal)
    }

    try? context.save()
}

