//
//  BrowserKind.swift
//  Snoopy
//
//  Created by Purav Manot on 19/04/25.
//

import Foundation

public enum BrowserKind: String, CaseIterable, Codable {
    case safari, chrome, arc
    
    public var engine: BrowserEngine {
        switch self {
            case .safari: return .webkit
            case .chrome, .arc: return .chromium
        }
    }
    
    public var defaultURL: URL {
        switch self {
            case .safari:
                return URL.homeDirectory
                    .appending("Library/Safari")
                    .appending(path: "History.db", directoryHint: .notDirectory)
            case .chrome:
                return URL.homeDirectory
                    .appending("Library/Application Support/Google/Chrome/Default")
                    .appending(path: "History", directoryHint: .notDirectory)
            case .arc:
                return URL.homeDirectory
                    .appending("Library/Application Support/Arc/User Data/Default")
                    .appending(path: "History", directoryHint: .notDirectory)
        }
    }
}

extension BrowserKind: CustomStringConvertible {
    public var description: String {
        switch self {
            case .safari:
                return "Safari"
            case .chrome:
                return "Chrome"
            case .arc:
                return "Arc"
        }
    }
}

