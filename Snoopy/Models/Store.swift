//
//  Store.swift
//  Snoopy
//
//  Created by Purav Manot on 18/04/25.
//

import Foundation

@Observable
final class BrowserHistoryStore {
    private(set) var entries: [BrowserHistoryEntry] = []
    
    @MainActor
    func fetchHistory(from startDate: Date, to endDate: Date, using config: BrowserHistoryConfiguration = .init()) throws {
        var result: [BrowserHistoryEntry] = []
        
        for (kind, url) in config.urls {
            let entriesForKind: [BrowserHistoryEntry]
            
            switch kind.engine {
                case .webkit:
                    entriesForKind = try SafariHistoryProvider.readHistory(from: startDate, to: endDate, at: url)
                case .chromium:
                    entriesForKind = try ChromeHistoryProvider.readHistory(from: startDate, to: endDate, at: url)
            }
            
            result.append(contentsOf: entriesForKind)
        }
        
        entries = result.sorted { $0.visitTime > $1.visitTime }
    }
}
