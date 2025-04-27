//
//  Store.swift
//  Snoopy
//
//  Created by Purav Manot on 18/04/25.
//

import Foundation
import SnoopyApp

@Observable
public final class BrowserHistoryStore: @unchecked Sendable {
    public var document: BrowserHistoryDocument = .init(entries: [])
    
    public private(set) var entries: [BrowserHistoryEntry] = []
    
    public init() {
        
    }
    
    public func fetchHistory(
        from startDate: Date,
        to endDate: Date,
        using config: BrowserHistoryConfiguration = .init()
    ) async throws {
        let aggregated = try await withThrowingTaskGroup(of: [BrowserHistoryEntry].self) { group in
            for (kind, url) in config.urls {
                group.addTask {
                    switch kind {
                        case .safari:
                            return try await SafariHistoryProvider.readHistory(from: startDate, to: endDate, at: url)
                        case .chrome:
                            return try await ChromeHistoryProvider.readHistory(from: startDate, to: endDate, at: url)
                        case .arc:
                            return try await ArcHistoryProvider.readHistory(from: startDate, to: endDate, at: url)
                    }
                }
            }
            
            var combined: [BrowserHistoryEntry] = []
            for try await subset in group {
                combined.append(contentsOf: subset)
            }
            return combined
        }
        
        entries = aggregated.sorted { $0.visitTime > $1.visitTime }
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
