//
//  BrowserHistoryConfiguration.swift
//  Snoopy
//
//  Created by Purav Manot on 18/04/25.
//

import Foundation

struct BrowserHistoryConfiguration {
    var paths: [BrowserKind: String]
    
    init(paths: [BrowserKind: String] = Self.defaultPaths) {
        self.paths = paths
    }
    
    subscript(_ kind: BrowserKind) -> String? {
        paths[kind]
    }
    
    static let defaultPaths: [BrowserKind: String] = [
        .safari: "~/Library/Safari/History.db",
        .chrome: "~/Library/Application Support/Google/Chrome/Default/History",
        .arc: "~/Library/Application Support/Arc/User Data/Default/History"
    ]
}
