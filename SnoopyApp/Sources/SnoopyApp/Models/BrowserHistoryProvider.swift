//
//  BrowserHistoryProvider.swift
//  Snoopy
//
//  Created by Purav Manot on 18/04/25.
//

import FoundationX
import Swallow
import SwallowMacrosClient
import SQLite3
import AppKit

public protocol BrowserHistoryProvider {
    static var kind: BrowserKind { get }
    @MainActor
    static func readHistory(from: Date, to: Date, at url: URL) async throws -> [BrowserHistoryEntry]
}

extension BrowserHistoryProvider {
    public static func readHistory(
        from: Date,
        to: Date,
        at url: URL
    ) async throws -> [BrowserHistoryEntry] {
        let directory = url._unsandboxedURL.deletingLastPathComponent()
        
        return try await FileManager.default.withUserGrantedAccess(to: directory, scope: .directory) { newURL in
            guard let copiedURL = newURL.copyToTempURL() else { return [] }
            return try await readHistoryInternal(
                from: from,
                to: to,
                dbURL: copiedURL.appending(path: url.lastPathComponent)
            )
        }
    }
    
    // MARK: - Private
    
    /// Performs the heavy SQLite work off the main thread.
    private static func readHistoryInternal(
        from: Date,
        to: Date,
        dbURL: URL
    ) async throws -> [BrowserHistoryEntry] {
        try await Task.detached(priority: .high) {
            try readHistorySync(from: from, to: to, dbURL: dbURL)
        }.value
    }
    
    /// Extracted synchronous query code.
    private static func readHistorySync(
        from: Date,
        to: Date,
        dbURL: URL
    ) throws -> [BrowserHistoryEntry] {
        var results: [BrowserHistoryEntry] = []
        let query = kind.engine.query
        let (lower, upper) = kind.engine.encodeBounds(start: from, end: to)
        
        var db: OpaquePointer?
        var statement: OpaquePointer?
        
        guard sqlite3_open_v2(
            dbURL.path,
            &db,
            SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX,
            nil
        ) == SQLITE_OK else {
            let message = sqlite3_errmsg(db).map { String(cString: $0) } ?? "Unknown error"
            sqlite3_close(db)
            throw NSError(domain: "BrowserHistory", code: 1001,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to open database: \(message)"])
        }
        defer { sqlite3_close(db) }
        
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            let message = sqlite3_errmsg(db).map { String(cString: $0) } ?? "Unknown error"
            throw NSError(domain: "BrowserHistory", code: 1002,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to prepare SQL: \(message)"])
        }
        defer { sqlite3_finalize(statement) }
        
        if kind.engine.defaultBrowserKind == .chrome || kind.engine.defaultBrowserKind == .arc {
            sqlite3_bind_int64(statement, 1, Int64(lower))
            sqlite3_bind_int64(statement, 2, Int64(upper))
        } else {
            sqlite3_bind_double(statement, 1, lower)
            sqlite3_bind_double(statement, 2, upper)
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let urlCStr = sqlite3_column_text(statement, kind.engine.urlColumnIndex) else { continue }
            let url = String(cString: urlCStr)
            let title = sqlite3_column_text(statement, kind.engine.titleColumnIndex)
                .map { String(cString: $0) } ?? "(no title)"
            
            let visitTime: Date = {
                if kind.engine == .chromium {
                    let raw = sqlite3_column_int64(statement, kind.engine.timeColumnIndex)
                    return kind.engine.decodeVisitTime(Double(raw))
                } else {
                    let raw = sqlite3_column_double(statement, kind.engine.timeColumnIndex)
                    return kind.engine.decodeVisitTime(raw)
                }
            }()
            
            results.append(.init(title: title, url: url, visitTime: visitTime, browser: kind))
        }
        
        return results
    }
}


extension URL {
    public var _isSandboxedURL: Bool? {
        get {
            guard let bundleIdentifier: String = Bundle.main.bundleIdentifier else {
                return nil
            }
            
            let sandboxPrefix: String = "/Users/\(NSUserName())/Library/Containers/\(bundleIdentifier)/Data"
            
            guard self.path.hasPrefix(sandboxPrefix) else {
                return false
            }
            
            return true
        }
    }
    
    var _unsandboxedURL: URL {
        _estimatedUnsandboxedPath.map({ URL(fileURLWithPath: $0) }) ?? self
    }
    
    fileprivate var _estimatedUnsandboxedPath: String? {
        guard let bundleIdentifier: String = Bundle.main.bundleIdentifier else {
            return nil
        }
        
        let sandboxPrefix: String = "/Users/\(NSUserName())/Library/Containers/\(bundleIdentifier)/Data"
        let nonSandboxPrefix: String = "/Users/\(NSUserName())/"
        
        guard self.path.hasPrefix(sandboxPrefix) else {
            return nil
        }
        
        var result: String = String(
            self.path
                .dropPrefixIfPresent(sandboxPrefix)
                .dropPrefixIfPresent("/")
                .dropSuffixIfPresent("/")
        )
        
        assert(nonSandboxPrefix.hasSuffix("/"))
        
        result = nonSandboxPrefix + result
        
        let url = URL(fileURLWithPath: result)
        
        if url.path.contains("//") {
            runtimeIssue("Malformed URL: \(self)")
        }
        
        return result
    }
}

extension URL {
    /// Creates a temporary URL by copying the contents of the original URL
    /// - Returns: A new URL pointing to the temporary copy, or nil if the operation failed
    func copyToTempURL() -> URL? {
        do {
            // Create a temporary directory URL
            let tempDirectoryURL = FileManager.default.temporaryDirectory
            
            // Generate a unique filename using UUID
            let uniqueFilename = UUID().uuidString
            
            // Get the original URL's file extension if it exists
            let fileExtension = self.pathExtension
            
            // Create the destination URL with the same extension
            let destinationFilename = fileExtension.isEmpty ? uniqueFilename : "\(uniqueFilename).\(fileExtension)"
            let destinationURL = tempDirectoryURL.appendingPathComponent(destinationFilename)
            
            // Copy the file from original URL to temp URL
            try FileManager.default.copyItem(at: self, to: destinationURL)
            
            return destinationURL
        } catch {
            return nil
        }
    }
}
