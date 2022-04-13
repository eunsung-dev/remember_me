//
//  remember_meApp.swift
//  remember_me
//
//  Created by 최은성 on 2022/04/13.
//

import SwiftUI

@main
struct remember_meApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
