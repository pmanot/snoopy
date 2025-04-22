//
//  BrowserEngine.swift
//  Snoopy
//
//  Created by Purav Manot on 19/04/25.
//

import Foundation

public enum BrowserEngine {
    case webkit
    case chromium
    
    public var query: String {
        switch self {
            case .webkit:
                return """
                SELECT history_items.id, history_items.url, history_visits.title, history_visits.visit_time
                FROM history_visits
                JOIN history_items ON history_visits.history_item = history_items.id
                WHERE visit_time BETWEEN ? AND ?
                ORDER BY visit_time DESC;
                """
            case .chromium:
                return """
                SELECT urls.url, urls.title, visits.visit_time
                FROM visits
                JOIN urls ON visits.url = urls.id
                WHERE visits.visit_time BETWEEN ? AND ?
                ORDER BY visits.visit_time DESC;
                """
        }
    }
    
    public var urlColumnIndex: Int32 {
        switch self {
            case .webkit: return 1
            case .chromium: return 0
        }
    }
    
    public var titleColumnIndex: Int32 {
        switch self {
            case .webkit: return 2
            case .chromium: return 1
        }
    }
    
    public var timeColumnIndex: Int32 {
        switch self {
            case .webkit: return 3
            case .chromium: return 2
        }
    }
    
    public func decodeVisitTime(_ raw: Double) -> Date {
        switch self {
            case .webkit:
                return Date(timeIntervalSince1970: raw + 978307200)
            case .chromium:
                return Date(timeIntervalSince1970: (raw / 1_000_000) - 11644473600)
        }
    }
    
    public func encodeBounds(start: Date, end: Date) -> (Double, Double) {
        switch self {
            case .webkit:
                let base = Date(timeIntervalSince1970: 978307200)
                return (start.timeIntervalSince(base), end.timeIntervalSince(base))
            case .chromium:
                return (
                    (start.timeIntervalSince1970 + 11644473600) * 1_000_000,
                    (end.timeIntervalSince1970 + 11644473600) * 1_000_000
                )
        }
    }
    
    public var defaultBrowserKind: BrowserKind {
        switch self {
            case .webkit: return .safari
            case .chromium: return .chrome // can override downstream if needed
        }
    }
}
