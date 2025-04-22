//
//  URLSelectionView.swift
//  Snoopy
//
//  Created by Purav Manot on 21/04/25.
//

import SwiftUI

struct DomainSelectionView: View {
    var domains: [URL]
    
    @State private var selection: Set<URL> = []
    
    var body: some View {
        List {
            ForEach(domains, id: \.self) { domain in
                Button {
                    toggleSelection(for: domain)
                } label: {
                    HStack {
                        Image(systemName: selection.contains(domain) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selection.contains(domain) ? .accentColor : .secondary)
                        
                        Spacer()
                        
                        Text(domain.absoluteString)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .padding(.leading, 4)
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private func toggleSelection(for domain: URL) {
        if selection.contains(domain) {
            selection.remove(domain)
        } else {
            selection.insert(domain)
        }
    }
}

#Preview {
    DomainSelectionView(domains: [])
}
