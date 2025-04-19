//
//  ContentView.swift
//  Snoopy
//
//  Created by Purav Manot on 17/04/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("safariPath") var safariPath: String = "~/Library/Safari/History.db"
    @AppStorage("chromePath") var chromePath: String = "~/Library/Application Support/Google/Chrome/Default/History"
    @AppStorage("arcPath") var arcPath: String = "~/Library/Application Support/Arc/User Data/Default/History"
    
    enum Tab: String, CaseIterable, Identifiable {
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
    
    @State private var selection: Tab? = .all
    @State private var store = BrowserHistoryStore()
    
    var body: some View {
        NavigationSplitView {
            List(Tab.allCases, selection: $selection) { browser in
                Label(browser.rawValue.capitalized, systemImage: browser.iconName)
                    .tag(browser, includeOptional: true)
            }
            .navigationTitle("Browsers")
            .scrollContentBackground(.hidden)
        } detail: {
            TableView(filter: selection?.kind)
                .environment(store)
                .background(Material.bar)
        }
    }
}

extension ContentView {
    struct TableView: View {
        @Environment(BrowserHistoryStore.self) var store: BrowserHistoryStore
        @State private var fromDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        @State private var toDate: Date = Date()
        
        var filter: BrowserKind? = nil
        
        var filteredEntries: [BrowserHistoryEntry] {
            guard let filter else { return store.entries }
            return store.entries.filter { $0.browser == filter }
        }
        
        var body: some View {
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
            .scrollContentBackground(.hidden)
            .toolbarBackgroundVisibility(.visible, for: .windowToolbar)
            .toolbarBackground(.bar, for: .windowToolbar)
            .toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    DatePicker("From", selection: $fromDate, displayedComponents: .date)

                    DatePicker("To", selection: $toDate, displayedComponents: .date)

                    Spacer()
                    
                    Button("Load") {
                        store.fetchHistory(from: fromDate, to: toDate)
                    }
                    .controlSize(.large)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Export") {
                        
                    }
                    .controlSize(.large)
                }
            }
            .task {
                store.fetchHistory(from: fromDate, to: toDate)
            }
        }
    }
}

#Preview {
    ContentView()
}
