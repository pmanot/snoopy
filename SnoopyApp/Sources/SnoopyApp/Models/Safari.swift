import Foundation
import SQLite3

struct SafariHistoryProvider: BrowserHistoryProvider {
    static var kind: BrowserKind { .safari }
}
