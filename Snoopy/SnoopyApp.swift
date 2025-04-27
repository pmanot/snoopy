//
//  SnoopyApp.swift
//  Snoopy
//
//  Created by Purav Manot on 17/04/25.
//

import SwiftUI
import SnoopyApp

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
        
        Settings {
            SettingsView()
        }
        
        DocumentGroup(newDocument: BrowserHistoryDocument(entries: [])) { file in
            DocumentView(document: file.document)
        }
    }
}

