//
//  TraceApp.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import SwiftUI
import SwiftData

@main
struct TraceApp: App {
    // 建立 Swift Data Container，所有 @Model 皆共用
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DiaryEntry.self,
            Goal.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let container = try! ModelContainer(for: schema, configurations: [config])
        
        // 預載入假資料
        preloadMockDataIfNeeded(context: container.mainContext)
        
        return container
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
