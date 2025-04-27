//
//  ContentView.swift
//  Snoopy
//
//  Created by Purav Manot on 17/04/25.
//

import Diagnostics
import SnoopyApp
import SwiftUI

struct ContentView: View {
    @AppStorage("safariPath") var safariPath: String = "~/Library/Safari/History.db"
    @AppStorage("chromePath") var chromePath: String = "~/Library/Application Support/Google/Chrome/Default/History"
    @AppStorage("arcPath") var arcPath: String = "~/Library/Application Support/Arc/User Data/Default/History"
    
    @State private var selection: Tab? = .all
    @State private var store = BrowserHistoryStore()
    @State private var showExportSheet: Bool = false
    
    var body: some View {
        NavigationSplitView {
            List(Tab.allCases, selection: $selection) { browser in
                Label(browser.rawValue.capitalized, systemImage: browser.iconName)
                    .tag(browser, includeOptional: true)
            }
            .navigationTitle("Browsers")
            .scrollContentBackground(.hidden)
        } detail: {
            TableView(showExportSheet: $showExportSheet, filter: selection?.kind)
                .environment(store)
                .background(Material.bar)
        }
        /*
        .popover(isPresented: $showExportSheet) {
            DomainSelectionView(domains: store.domains())
                .presentationCompactAdaptation(.popover)
        }
        */
    }
}

extension ContentView {
    struct TableView: View {
        @Environment(BrowserHistoryStore.self) var store: BrowserHistoryStore
        @State private var fromDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        @State private var toDate: Date = Date()
        
        @Binding var showExportSheet: Bool
        
        var filter: BrowserKind? = nil
        
        var filteredEntries: [BrowserHistoryEntry] {
            guard let filter else { return store.entries }
            return store.entries.filter { $0.browser == filter }
        }
        
        var body: some View {
            Table(filteredEntries) {
                TableColumn("Browser") { item in
                    Label {
                        Text(item.browser.rawValue.capitalized)
                    } icon: {
                        Image(nsImage: item.browser.icon ?? NSImage())
                    }
                    .font(.body)
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
                        Task {
                            #try(.optimistic) {
                                try await store.fetchHistory(from: fromDate, to: toDate)
                            }
                        }
                        
                    }
                    .controlSize(.large)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Export") {
                        showExportSheet = true
                    }
                    .controlSize(.large)
                }
            }
            .fileExporter(
                isPresented: $showExportSheet,
                document: BrowserHistoryDocument(entries: filteredEntries),
                contentType: .json
            ) { result in
                switch result {
                    case .success(let url):
                        print(url)
                        return
                    case .failure(let failure):
                        print(failure)
                }
            }
            .task {
                Task.detached {
                    do {
                        try await store.fetchHistory(from: fromDate, to: toDate)
                    } catch {
                        runtimeIssue(error)
                    }
                }
            }
        }
    }
}

extension ContentView {
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
}

#Preview {
    ContentView()
}
