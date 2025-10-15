//
//  LashesLamApp.swift
//  LashesLam
//
//  Created by Alejandro Mejia v on 15/10/25.
//

import SwiftUI
import CoreData

@main
struct LashesLamApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
