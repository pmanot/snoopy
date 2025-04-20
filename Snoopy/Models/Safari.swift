import Foundation
import SQLite3

struct SafariHistoryProvider: BrowserHistoryProvider {
    static let engine: BrowserEngine = .webkit
}
