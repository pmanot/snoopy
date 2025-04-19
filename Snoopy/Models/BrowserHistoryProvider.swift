//
//  BrowserHistoryProvider.swift
//  Snoopy
//
//  Created by Purav Manot on 18/04/25.
//

import Foundation

import Foundation
import SQLite3

protocol BrowserHistoryProvider {
    static var engine: BrowserEngine { get }
    static func readHistory(from: Date, to: Date, at path: String) -> [BrowserHistoryEntry]
}

extension BrowserHistoryProvider {
    static func readHistory(from: Date, to: Date, at path: String) -> [BrowserHistoryEntry] {
        let query = engine.query
        let (lower, upper) = engine.encodeBounds(start: from, end: to)
        let dbPath = copyDatabase(toTemporaryLocationFrom: path)
        
        var db: OpaquePointer?
        var statement: OpaquePointer?
        var results: [BrowserHistoryEntry] = []
        
        guard sqlite3_open(dbPath, &db) == SQLITE_OK else { return [] }
        defer { sqlite3_close(db) }
        
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(statement) }
        
        sqlite3_bind_double(statement, 1, lower)
        sqlite3_bind_double(statement, 2, upper)
        
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let urlCStr = sqlite3_column_text(statement, engine.urlColumnIndex) else { continue }
            
            let url = String(cString: urlCStr)
            let title = sqlite3_column_text(statement, engine.titleColumnIndex).map { String(cString: $0) } ?? "(no title)"
            let rawTime = sqlite3_column_double(statement, engine.timeColumnIndex)
            let visitTime = engine.decodeVisitTime(rawTime)
            
            results.append(.init(
                title: title,
                url: url,
                visitTime: visitTime,
                browser: engine.defaultBrowserKind
            ))
        }
        
        return results
    }
    
    private static func copyDatabase(toTemporaryLocationFrom path: String) -> String {
        let expanded = NSString(string: path).expandingTildeInPath
        let temp = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString + ".db").path
        
        do {
            try FileManager.default.copyItem(atPath: expanded, toPath: temp)
            return temp
        } catch {
            print("⚠️ Failed to copy DB to temp: \(error)")
            return expanded
        }
    }
}

