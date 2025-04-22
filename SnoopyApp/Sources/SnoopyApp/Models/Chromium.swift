import Foundation
import SQLite3

struct ChromeHistoryProvider: BrowserHistoryProvider {
    static var kind: BrowserKind { .chrome }
}

struct ArcHistoryProvider: BrowserHistoryProvider {
    static var kind: BrowserKind { .arc }
}
