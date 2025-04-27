//
//  BrowserHistoryEntry.swift
//  Snoopy
//
//  Created by Purav Manot on 18/04/25.
//

import Foundation

public struct BrowserHistoryEntry: Identifiable, Sendable {
    public let id: UUID = UUID()
    public let title: String
    public let url: String
    public let visitTime: Date
    public let browser: BrowserKind
}
