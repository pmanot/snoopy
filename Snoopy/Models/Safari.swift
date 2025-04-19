//
//  Safari.swift
//  Snoopy
//
//  Created by Purav Manot on 17/04/25.
//

import Foundation
import SQLite3

struct SafariHistoryProvider: BrowserHistoryProvider {
    static let engine: BrowserEngine = .webkit
}
