import Foundation
import SQLite3

public struct ChromeHistoryProvider: BrowserHistoryProvider {
    public static var kind: BrowserKind { .chrome }
}

public struct ArcHistoryProvider: BrowserHistoryProvider {
    public static var kind: BrowserKind { .arc }
}
