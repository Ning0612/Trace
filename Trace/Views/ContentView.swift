//
//  ContentView.swift
//  Trace
//
//  Created by 王政甯 on 2025/5/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("首頁", systemImage: "house") }
            JournalView().tabItem { Label("紀錄", systemImage: "book.closed") }
            GoalsView().tabItem { Label("目標", systemImage: "target") }
            CountdownView().tabItem { Label("倒數", systemImage: "hourglass") }
            ReviewView().tabItem { Label("回顧", systemImage: "chart.bar") }
        }
    }
}


#Preview {
    ContentView()
}
