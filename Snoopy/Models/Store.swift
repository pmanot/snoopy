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
    
    func fetchHistory(from startDate: Date, to endDate: Date, using config: BrowserHistoryConfiguration = .init()) {
        var result: [BrowserHistoryEntry] = []
        
        for (kind, path) in config.paths {
            guard FileManager.default.fileExists(atPath: NSString(string: path).expandingTildeInPath) else { continue }
            
            let entriesForKind: [BrowserHistoryEntry]
            
            switch kind.engine {
                case .webkit:
                    entriesForKind = SafariHistoryProvider.readHistory(from: startDate, to: endDate, at: path)
                case .chromium:
                    let adjustedKind = kind // override default browserKind if needed
                    entriesForKind = ChromeHistoryProvider.readHistory(from: startDate, to: endDate, at: path)
                        .map { entry in
                            BrowserHistoryEntry(
                                title: entry.title,
                                url: entry.url,
                                visitTime: entry.visitTime,
                                browser: adjustedKind
                            )
                        }
            }
            
            result.append(contentsOf: entriesForKind)
        }
        
        entries = result.sorted { $0.visitTime > $1.visitTime }
    }
}
