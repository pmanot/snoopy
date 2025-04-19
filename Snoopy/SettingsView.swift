//
//  SettingsView.swift
//  Snoopy
//
//  Created by Purav Manot on 18/04/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("safariPath") var safariPath: String = BrowserKind.safari.defaultPath
    @AppStorage("chromePath") var chromePath: String = BrowserKind.chrome.defaultPath
    @AppStorage("arcPath") var arcPath: String = BrowserKind.arc.defaultPath
    
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
