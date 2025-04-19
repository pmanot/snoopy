//
//  SettingsView.swift
//  Snoopy
//
//  Created by Purav Manot on 18/04/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("safariPath") var safariPath: String = "~/Library/Safari/History.db"
    @AppStorage("chromePath") var chromePath: String = "~/Library/Application Support/Google/Chrome/Default/History"
    @AppStorage("arcPath") var arcPath: String = #"~/Library/Application Support/Arc/User Data/Default/History"#
    
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
