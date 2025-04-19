import Foundation
import SQLite3

struct ChromeHistoryProvider: BrowserHistoryProvider {
    static let engine: BrowserEngine = .chromium
}
