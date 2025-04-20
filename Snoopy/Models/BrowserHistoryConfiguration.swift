//
//  BrowserHistoryConfiguration.swift
//  Snoopy
//
//  Created by Purav Manot on 18/04/25.
//

import Foundation

struct BrowserHistoryConfiguration {
    var urls: [BrowserKind: URL]
    
    init() {
        self.urls = Dictionary(uniqueKeysWithValues: BrowserKind.allCases.map { ($0, $0.defaultURL) })
    }
    
    subscript(_ kind: BrowserKind) -> URL? {
        urls[kind]
    }
}
