//
//  SmartStudyCompanionApp.swift
//  SmartStudyCompanion
//
//  Created by Andrew Anderson on 3/7/25.
//

import SwiftUI

@main
struct SmartStudyCompanionApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
