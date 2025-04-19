//
//  SnoopyApp.swift
//  Snoopy
//
//  Created by Purav Manot on 17/04/25.
//

import SwiftUI

@main
struct SnoopyApp: App {    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
        
        Settings {
            SettingsView()
        }
    }
}

