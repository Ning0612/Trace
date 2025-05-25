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
         "CompBall 是一款結合電腦組成原理的合成益智遊戲，靈感來自《西瓜遊戲》。玩家透過合成電晶體、邏輯閘等元件，一路升級到完整電腦。這個遊戲不只是玩樂，更是我試圖讓資訊工程知識以互動方式呈現的第一次挑戰。",
         [
            ("基本架構完成", "場景、物理碰撞、球體生成邏輯都跑起來了，整體流程已經很穩定。"),
            ("合成邏輯與延遲優化", "修正碰撞時的合成節奏，加入延遲動畫讓合體更自然、更有爽感。"),
            ("處理暫停邏輯", "新增暫停功能＋重新開始選項，處理中斷與 resume 的小 bug 花了不少時間。"),
            ("美術素材美化完成", "替換掉原本的 debug 風格球圖，加上發光動畫與主題配色後，整體質感有感提升。")
         ]),
        
        ("iOS Final Project APP", "2025-06-04", 0.8,
         "Trace 是一個記錄生活與成長軌跡的個人追蹤 App。初步架構與主要功能完成，但原本想實作的辭彙分析、AI 小幫手等進階功能因時間不夠只好暫緩。這是我第一次嘗試設計帶情感與目標性的工具，也體會到從無到有的每一步都不容易。",
         [
            ("初步架構完成", "基本的 SwiftData 模型與 UI 互動已經順利跑起來，資料也能保存。"),
            ("夢想牆畫面實作", "可以顯示倒數天數，還設計了圖示與進度條，視覺上有達到想像。"),
            ("加入 SwiftData 模型錯誤", "container 沒初始化導致整個 app 崩潰，debug 半天才找到原因。"),
            ("辭彙分析來不及實作", "原本想加 NLP 分析日記情緒，但現在只能先做最基礎功能。"),
            ("一人做兩個專案真的爆炸", "Game 和 App 都還沒收尾，時間壓力快頂不住，但也感覺到自己撐住了不少。")
         ]),

        ("Compiler Project 3 Code Generation", "2025-06-10", 0.0,
         "專案的最後階段，要把 AST 轉成中介碼甚至實際機器碼。這部分要處理 register 分配、block 結構與指令序列安排，是整個編譯器實作中最貼近「輸出程式碼」的一步。",
         [
            ("第一個 IR 模板", "試著產生 basic block，但 register 分配還沒搞懂。"),
            ("移除不使用文法", "把不需實作的文法都移除，尤其是陣列的實作，因為目前沒有實際使用。"),
            ("進度嚴重落後", "完全沒動靜，快來不及了，可能要通宵。")
        ]),

        ("Compiler Project 2 Parser", "2025-05-20", 1.0,
         "一開始卡在文法設計，Predictive Parsing 的 left factoring 很煩，後來做了語意檢查、嘗試 Constant folding，但踩了一堆 memory 問題，debug 到快瘋掉。",
         [
            ("語意分析初體驗", "第一次自己寫 semantic checker，光是型別對應就超麻煩。"),
            ("嘗試 Constant Folding", "設計了簡單 AST 優化規則，可以在 parse 階段直接化簡 3+5。"),
            ("new 與 delete 地獄", "new 了一堆 node 結果忘了 delete，跑一跑直接 segfault。"),
            ("以為交得出去…", "昨天還以為可以交，結果 parser 又突然 parse 錯誤格式就爆炸。")
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
            ("試著當自己產品經理", "設計了一週的 app wireframe，想想就覺得興奮。"),
            ("修改電子紙時鐘", "把之前的 e-ink 時鐘改成可以抓氣象資料來顯示溫度與天氣狀況，感覺很實用。"),
            ("逛 2025 Computex", "現場看到很多 AI PC、新型筆電與超輕量顯示器，讓人腦洞大開，靈感爆炸。"),
            ("期末後的犒賞計畫", "決定這學期一結束就要去吃一頓貴一點的日式燒肉，好好慰勞自己。")
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
        insertDiary(baseDate: date("2025-04-04"), entries: entries, goal: goal)
    }
    
    // === 回顧舊資料：一年前的期末 ===
    let pastGoal = Goal(
        title: "2024 年下學期期末週",
        detail: "回顧 2024 年底的期末週，計組、演算法考完後進入報告收尾階段，那年暑假開始感受到學業與壓力同時積累。",
        kind: .target,
        targetDate: date("2024-06-06"),
        progress: 1.0,
        imageName: "clock"
    )
    context.insert(pastGoal)

    let pastDiaries: [(String, String, String)] = [
        ("計組真的考完了", "2024-06-04", "計組終於考完了，最後一大題的架構根本不知道怎麼畫，但至少有寫點東西。"),
        ("最後一科也考完了", "2024-06-05", "演算法也考完了，應該輕鬆 Pass，最後一科考完了，剩下兩份報告了。")
    ]

    for (title, dateStr, text) in pastDiaries {
        let diary = DiaryEntry(
            title: title,
            date: date(dateStr),
            text: text,
            moodScore: Int.random(in: 2...4),
            goal: pastGoal
        )
        context.insert(diary)
    }


    try? context.save()
}

