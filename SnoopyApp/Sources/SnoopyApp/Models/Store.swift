//
//  Store.swift
//  Snoopy
//
//  Created by Purav Manot on 18/04/25.
//

import Foundation

@Observable
public final class BrowserHistoryStore: @unchecked Sendable {
    public private(set) var entries: [BrowserHistoryEntry] = []
    
    public init() {
        
    }
    
    @MainActor
    public func fetchHistory(from startDate: Date, to endDate: Date, using config: BrowserHistoryConfiguration = .init()) throws {
        var result: [BrowserHistoryEntry] = []
        
        for (kind, url) in config.urls {
            let entriesForKind: [BrowserHistoryEntry]
            
            switch kind {
                case .safari:
                    entriesForKind = try SafariHistoryProvider.readHistory(from: startDate, to: endDate, at: url)
                case .chrome:
                    entriesForKind = try ChromeHistoryProvider.readHistory(from: startDate, to: endDate, at: url)
                case .arc:
                    entriesForKind = try ArcHistoryProvider.readHistory(from: startDate, to: endDate, at: url)
            }
            
            result.append(contentsOf: entriesForKind)
        }
        
        entries = result.sorted { $0.visitTime > $1.visitTime }
    }
    
    public func domains() -> [URL] {
        var seenDomains = Set<String>()
        var result = [URL]()
        
        for entry in entries {
            guard let original = URL(string: entry.url),
                  var components = URLComponents(url: original, resolvingAgainstBaseURL: false) else {
                continue
            }
            
            components.path = ""
            components.query = nil
            components.fragment = nil
            
            guard let domainURL = components.url else { continue }
            
            let key = domainURL.absoluteString
            if seenDomains.insert(key).inserted {
                result.append(domainURL)
            }
        }
        
        return result
    }
    
    public func export(from startDate: Date, to endDate: Date, using config: BrowserHistoryConfiguration = .init()) throws -> [BrowserHistoryEntry] {
        return []
    }
}
