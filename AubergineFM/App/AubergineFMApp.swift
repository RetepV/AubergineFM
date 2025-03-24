//
//  AubergineFMApp.swift
//  AubergineFM
//
//  Created by Peter de Vroomen on 11-12-2024.
//

import SwiftUI
import SwiftData

@main
struct AubergineFMApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        AppGlobalEnvironment.shared.initializeExplicitly()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
