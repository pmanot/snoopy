//
//  BrowserHistoryEntry.swift
//  Snoopy
//
//  Created by Purav Manot on 18/04/25.
//

import Foundation

struct BrowserHistoryEntry: Identifiable {
    let id: UUID = UUID()
    let title: String
    let url: String
    let visitTime: Date
    let browser: BrowserKind
}
