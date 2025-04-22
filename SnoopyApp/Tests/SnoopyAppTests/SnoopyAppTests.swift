import Testing
@testable import SnoopyApp
import Foundation
import SQLite3
import SwiftUI

@Suite
struct Tests {
    @State var store = BrowserHistoryStore()

    @Test
    func testReadingDummyDBs() async throws {
        var config: BrowserHistoryConfiguration = BrowserHistoryConfiguration()
        
        config.urls[.safari] = Bundle.module.url(forResource: "dummy_safari", withExtension: "db")!
        config.urls[.arc] = Bundle.module.url(forResource: "dummy_arc", withExtension: "db")!
        config.urls[.chrome] = Bundle.module.url(forResource: "dummy_chrome", withExtension: "db")!

        try await store.fetchHistory(from: .distantPast, to: .distantFuture, using: config)
        
        // Verify the results
        #expect(store.entries.count > 0, "Should have loaded some entries")
        
        // Check we have entries from each browser
        let safariEntries: [BrowserHistoryEntry] = store.entries.filter { $0.browser == .safari }
        let chromeEntries: [BrowserHistoryEntry] = store.entries.filter { $0.browser == .chrome }
        let arcEntries: [BrowserHistoryEntry] = store.entries.filter { $0.browser == .arc }
        
        #expect(!safariEntries.isEmpty, "Should have Safari entries")
        #expect(!chromeEntries.isEmpty, "Should have Chrome entries")
        #expect(!arcEntries.isEmpty, "Should have Arc entries")
        
        // Print sample entries for visual inspection
        print("Safari count: \(safariEntries.count)")
        print("Chrome count: \(chromeEntries.count)")
        print("Arc count: \(arcEntries.count)")
        
        if let safariEntry = safariEntries.first {
            print("Safari sample: \(safariEntry.title) - \(safariEntry.url)")
        }
        
        if let chromeEntry = chromeEntries.first {
            print("Chrome sample: \(chromeEntry.title) - \(chromeEntry.url)")
        }
        
        if let arcEntry = arcEntries.first {
            print("Arc sample: \(arcEntry.title) - \(arcEntry.url)")
        }
    }
    
    /// Helper method to create custom paths to our dummy DB files
    private func createCustomPath(for browser: BrowserKind) -> URL {
        let filename = "dummy_\(browser.rawValue).db"
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Downloads")
            .appendingPathComponent(filename)
        print(url)
        
        return url
    }
}
