//
//  File.swift
//  SnoopyApp
//
//  Created by Purav Manot on 26/04/25.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

public struct BrowserHistoryDocument: Sendable {
    public var entries: [BrowserHistoryEntry]
    
    public init(entries: [BrowserHistoryEntry]) {
        self.entries = entries
    }
}


extension BrowserHistoryDocument: FileDocument {
    nonisolated(unsafe) public static var readableContentTypes: [UTType] = [UTType.plainText, UTType.json]
    
    public init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.entries = try JSONDecoder().decode([BrowserHistoryEntry].self, from: data)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(entries)
        
        return FileWrapper(regularFileWithContents: data)
    }
}
