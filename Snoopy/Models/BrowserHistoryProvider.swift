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

protocol BrowserHistoryProvider {
    static var engine: BrowserEngine { get }
    @MainActor
    static func readHistory(from: Date, to: Date, at url: URL) throws -> [BrowserHistoryEntry]
}

extension BrowserHistoryProvider {
    @MainActor
    static func readHistory(from: Date, to: Date, at url: URL) throws -> [BrowserHistoryEntry] {
        let directory: URL = url._unsandboxedURL.deletingLastPathComponent()
        
        return try FileManager.default.withUserGrantedAccess(to: directory, scope: .directory) { newURL in
            guard let copiedURL = newURL.copyToTempURL() else { return [] }
            return try readHistoryInternal(from: from, to: to, dbURL: copiedURL.appending(path: url.lastPathComponent))
        }
    }
    
    private static func readHistoryInternal(from: Date, to: Date, dbURL: URL) throws -> [BrowserHistoryEntry] {
        var results: [BrowserHistoryEntry] = []
        
        let query = engine.query
        let (lower, upper) = engine.encodeBounds(start: from, end: to)
        
        var db: OpaquePointer?
        var statement: OpaquePointer?
        
        // Open the database
        let openResult = sqlite3_open(dbURL.path, &db)
        guard openResult == SQLITE_OK else {
            let errorMessage = sqlite3_errmsg(db).map { String(cString: $0) } ?? "Unknown error"
            sqlite3_close(db)
            throw NSError(domain: "BrowserHistory", code: 1001,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to open database: \(errorMessage)"])
        }
        defer { sqlite3_close(db) }
        
        // Prepare the SQL statement
        let prepareResult = sqlite3_prepare_v2(db, query, -1, &statement, nil)
        guard prepareResult == SQLITE_OK else {
            let errorMessage = sqlite3_errmsg(db).map { String(cString: $0) } ?? "Unknown error"
            throw NSError(domain: "BrowserHistory", code: 1002,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to prepare SQL statement: \(errorMessage)"])
        }
        defer { sqlite3_finalize(statement) }
        
        // Bind parameters
        if engine.defaultBrowserKind == .chrome || engine.defaultBrowserKind == .arc {
            // For Chromium, we need to bind int64 parameters
            sqlite3_bind_int64(statement, 1, Int64(lower))
            sqlite3_bind_int64(statement, 2, Int64(upper))
        } else {
            // For Safari, we use double parameters
            sqlite3_bind_double(statement, 1, lower)
            sqlite3_bind_double(statement, 2, upper)
        }
        
        // Execute the query and process results
        while true {
            let stepResult = sqlite3_step(statement)
            
            if stepResult == SQLITE_ROW {
                guard let urlCStr = sqlite3_column_text(statement, engine.urlColumnIndex) else {
                    continue
                }
                
                let url = String(cString: urlCStr)
                let title = sqlite3_column_text(statement, engine.titleColumnIndex).map { String(cString: $0) } ?? "(no title)"
                
                // Handle time differently based on browser engine
                let visitTime: Date
                if engine.defaultBrowserKind == .chrome || engine.defaultBrowserKind == .arc {
                    let rawTime = sqlite3_column_int64(statement, engine.timeColumnIndex)
                    visitTime = engine.decodeVisitTime(Double(rawTime))
                } else {
                    let rawTime = sqlite3_column_double(statement, engine.timeColumnIndex)
                    visitTime = engine.decodeVisitTime(rawTime)
                }
                
                results.append(.init(
                    title: title,
                    url: url,
                    visitTime: visitTime,
                    browser: engine.defaultBrowserKind
                ))
            } else if stepResult == SQLITE_DONE {
                break
            } else {
                let errorMessage = sqlite3_errmsg(db).map { String(cString: $0) } ?? "Unknown error"
                throw NSError(domain: "BrowserHistory", code: 1003,
                              userInfo: [NSLocalizedDescriptionKey: "Failed to execute query: \(errorMessage)"])
            }
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

extension FileManager {
    public func _withTemporaryCopy<Result>(
        of url: URL,
        perform body: (URL) throws -> Result
    ) throws -> Result {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathComponent(url.lastPathComponent)
        try copyItem(at: url, to: tempFileURL)
        
        do {
            let result = try body(tempFileURL)
            
            return result
        } catch {
            throw error
        }
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
