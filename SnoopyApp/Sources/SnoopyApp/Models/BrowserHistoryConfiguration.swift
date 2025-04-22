//
//  BrowserHistoryConfiguration.swift
//  Snoopy
//
//  Created by Purav Manot on 18/04/25.
//

import Foundation

public struct BrowserHistoryConfiguration {
    public var urls: [BrowserKind: URL]
    
    public init() {
        self.urls = Dictionary(uniqueKeysWithValues: BrowserKind.allCases.map { ($0, $0.defaultURL) })
    }
    
    public subscript(_ kind: BrowserKind) -> URL? {
        urls[kind]
    }
}
