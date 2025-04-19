//
//  BrowserKind.swift
//  Snoopy
//
//  Created by Purav Manot on 19/04/25.
//

import Foundation

enum BrowserKind: String, CaseIterable, Codable {
    case safari, chrome, arc
    
    var engine: BrowserEngine {
        switch self {
            case .safari: return .webkit
            case .chrome, .arc: return .chromium
        }
    }
    
    var defaultPath: String {
        switch self {
            case .safari:
                return "~/Library/Safari/History.db"
            case .chrome:
                return "~/Library/Application Support/Google/Chrome/Default/History"
            case .arc:
                return "~/Library/Application Support/Arc/User Data/Default/History"
        }
    }
}

extension BrowserKind: CustomStringConvertible {
    var description: String {
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
