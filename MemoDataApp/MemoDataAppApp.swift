//
//  MemoDataAppApp.swift
//  MemoDataApp
//
//  Created by SeongKook on 4/22/24.
//

import SwiftUI

@main
struct MemoDataAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Memo.self)
        }
    }
}
