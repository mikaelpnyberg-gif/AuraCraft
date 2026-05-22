//
//  AuraCraftApp.swift
//  AuraCraft
//
//  Created by MNyberg on 20/05/2026.
//

import SwiftUI
import SwiftData

@main
struct AuraCraftApp: App {
    @StateObject private var homeKit: HomeKitManager
    @StateObject private var storeManager = StoreManager()

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
        let homeKit = HomeKitManager()
        _homeKit = StateObject(wrappedValue: homeKit)    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(homeKit)
                .environmentObject(storeManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
