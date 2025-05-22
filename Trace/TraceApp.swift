//
//  TraceApp.swift
//  Trace
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
            Milestone.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
