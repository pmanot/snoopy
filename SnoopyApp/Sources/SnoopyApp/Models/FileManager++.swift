//
//  FileManager++.swift
//  Snoopy
//
//  Created by Purav Manot on 21/04/25.
//

import Foundation

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
