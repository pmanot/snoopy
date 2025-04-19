//
//  RootView.swift
//  Snoopy
//
//  Created by Purav Manot on 18/04/25.
//

import SwiftUI

struct RootView: View {
    @AppStorage("safariPath") var safariPath: String = "~/Library/Safari/History.db"
    @AppStorage("chromePath") var chromePath: String = "~/Library/Application Support/Google/Chrome/Default/History"
    @AppStorage("arcPath") var arcPath: String = "~/Library/Application Support/Arc/User Data/Default/History"
    
    enum Browser: String, CaseIterable, Identifiable {
        case safari, chrome, arc, all
        var id: String { rawValue }
        var iconName: String {
            switch self {
                case .safari: return "safari"
                case .chrome: return "globe"
                case .arc: return "a.circle"
                case .all: return "rectangle.stack"
            }
        }
        
        var kind: BrowserKind? {
            switch self {
                case .safari: return .safari
                case .chrome: return .chrome
                case .arc: return .arc
                case .all: return nil
            }
        }
    }
    
    @State private var selection: Browser? = .all
    @State private var store = BrowserHistoryStore()
    
    var body: some View {
        NavigationSplitView {
            List(Browser.allCases, selection: $selection) { browser in
                Label(browser.rawValue.capitalized, systemImage: browser.iconName)
                    .tag(browser, includeOptional: true)
            }
            .navigationTitle("Browsers")
        } detail: {
            UnifiedHistoryTableView(filter: selection?.kind)
                .environment(store)
        }
    }
}


struct UnifiedHistoryTableView: View {
    @Environment(BrowserHistoryStore.self) var store: BrowserHistoryStore
    @State private var fromDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @State private var toDate: Date = Date()
    
    var filter: BrowserKind? = nil
    
    var filteredEntries: [BrowserHistoryEntry] {
        guard let filter else { return store.entries }
        return store.entries.filter { $0.browser == filter }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                DatePicker("From", selection: $fromDate, displayedComponents: .date)
                DatePicker("To", selection: $toDate, displayedComponents: .date)
                Button("Load") {
                    store.fetchHistory(from: fromDate, to: toDate)
                }
            }
            .padding()
            
            Table(filteredEntries) {
                TableColumn("Browser") { item in
                    Text(item.browser.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                TableColumn("Title") { item in
                    Text(item.title).lineLimit(1)
                }
                TableColumn("URL") { item in
                    Text(item.url).foregroundStyle(.gray).lineLimit(1)
                }
                TableColumn("Visit Time") { item in
                    Text(item.visitTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                }
            }
        }
        .task {
            store.fetchHistory(from: fromDate, to: toDate)
        }
    }
}


#Preview {
    RootView()
}
