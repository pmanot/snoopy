//
//  BrowserKind.swift
//  Snoopy
//
//  Created by Purav Manot on 19/04/25.
//

import Foundation
import AppKit

public enum BrowserKind: String, CaseIterable, Codable, Sendable {
    case safari, chrome, arc
        
    nonisolated(unsafe) private static var _iconCache: [BrowserKind: NSImage] = [:]
        
    public var engine: BrowserEngine {
        switch self {
            case .safari:         return .webkit
            case .chrome, .arc:   return .chromium
        }
    }
    
    public var defaultURL: URL {
        switch self {
            case .safari:
                URL.homeDirectory
                    .appending("Library/Safari")
                    .appending(path: "History.db", directoryHint: .notDirectory)
            case .chrome:
                URL.homeDirectory
                    .appending("Library/Application Support/Google/Chrome/Default")
                    .appending(path: "History", directoryHint: .notDirectory)
            case .arc:
                URL.homeDirectory
                    .appending("Library/Application Support/Arc/User Data/Default")
                    .appending(path: "History", directoryHint: .notDirectory)
        }
    }
    
    public var bundleIdentifier: String {
        switch self {
            case .safari: "com.apple.Safari"
            case .chrome: "com.google.Chrome"
            case .arc:    "company.thebrowser.Browser"
        }
    }
    
    public var icon: NSImage {
        let fallback: NSImage = NSImage(symbolName: "safari", variableValue: 0) ?? NSImage()
        let desiredSize = NSSize(width: 24, height: 24)
        
        if let cached = Self._iconCache[self] {
            return cached
        }
        
        let originalIcon: NSImage = {
            guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
                return fallback
            }
            
            return NSWorkspace.shared.icon(forFile: appURL.path)
        }()
        
        let resizedIcon = NSImage(size: desiredSize)
        resizedIcon.lockFocus()
        
        NSGraphicsContext.current?.imageInterpolation = .high
        originalIcon.draw(in: NSRect(origin: .zero, size: desiredSize),
                          from: NSRect(origin: .zero, size: originalIcon.size),
                          operation: .copy,
                          fraction: 1.0)
        
        resizedIcon.unlockFocus()
        
        Self._iconCache[self] = resizedIcon
        
        return resizedIcon
    }
}

// MARK: - Conformances

extension BrowserKind: CustomStringConvertible {
    public var description: String {
        switch self {
            case .safari: "Safari"
            case .chrome: "Chrome"
            case .arc:    "Arc"
        }
    }
}
