import Foundation
import SQLite3

public struct SafariHistoryProvider: BrowserHistoryProvider {
    public static var kind: BrowserKind { .safari }
}
