//
//  SettingsView.swift
//  Snoopy
//
//  Created by Purav Manot on 18/04/25.
//

import SwiftUI
import SnoopyApp

struct SettingsView: View {
    @AppStorage("safariPath") var safariPath: String = BrowserKind.safari.defaultURL.path()
    @AppStorage("chromePath") var chromePath: String = BrowserKind.chrome.defaultURL.path()
    @AppStorage("arcPath") var arcPath: String = BrowserKind.arc.defaultURL.path()
    
    var body: some View {
        Form {
            Section(header: Text("History File Paths")) {
                TextField("Safari", text: $safariPath)
                TextField("Chrome", text: $chromePath)
                TextField("Arc", text: $arcPath)
            }
        }
        .padding()
        .frame(width: 400)
    }
}

#Preview {
    SettingsView()
}
