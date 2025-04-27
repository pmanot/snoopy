//
//  DocumentView.swift
//  Snoopy
//
//  Created by Purav Manot on 26/04/25.
//

import Foundation
import SnoopyApp
import SwiftUI
import QuickLookUI
import QuickLook
import Browser

struct DocumentView: View {
    @State private var browser = Browser()
    @State private var url: URL? = nil
    @State private var selection: BrowserHistoryEntry.ID? = nil
    
    var document: BrowserHistoryDocument
    
    var body: some View {
        Table(of: BrowserHistoryEntry.self, selection: $selection) {
            TableColumn("Browser") { item in
                Label {
                    Text(item.browser.rawValue.capitalized)
                } icon: {
                    Image(nsImage: item.browser.icon)
                }
                .font(.body)
                .foregroundStyle(.secondary)
            }
            
            TableColumn("Title") { item in
                Text(item.title)
                    .lineLimit(1)
            }
            
            TableColumn("URL") { item in
                Text(item.url)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            TableColumn("Visit Time") { item in
                Text(item.visitTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
            }
        } rows: {
            ForEach(document.entries) { entry in
                TableRow(entry)
            }
        }
        .quickLookPreview($url, in: document.entries.compactMap { URL(string: $0.url) })
        .onKeyPress(.space) {
            guard let selection else { return .ignored }
            guard let entry: BrowserHistoryEntry = document.entries.first (where: { $0.id == selection }) else { return .ignored }
            
            if self.url?.absoluteString != entry.url {
                self.url = URL(string: entry.url)
            } else {
                self.url = nil
            }
            
            return .handled
        }
        .onChange(of: selection) {
            guard let entry: BrowserHistoryEntry = document.entries.first (where: { $0.id == selection }) else { return }
            
            Task {
                do {
                    try browser.load(entry.url)
                } catch {
                    print(error)
                }
            }
        }
        .inspector(isPresented: .constant(true)) {
            BrowserView(browser: browser)
                .padding(5)
                .background {
                    VisualEffectView(material: .popover)
                        .ignoresSafeArea(.all)
                }
        }
    }
}

#Preview {
    DocumentView(document: .init(entries: []))
        .environment(BrowserHistoryStore())
}
