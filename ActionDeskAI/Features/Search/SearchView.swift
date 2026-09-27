import SwiftUI

struct SearchView: View {
    @Environment(AppStore.self) private var store
    @State private var query = ""

    private var results: [AdminItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        return store.items.filter { item in
            if q.contains("unresolved") { return ![.resolved, .archived].contains(item.status) }
            if q.contains("waiting") { return item.status == .waiting }
            if q.contains("renew") { return item.category == .subscriptions || item.category == .insurance }
            if q.contains("bill") { return item.category == .bills }
            if q.contains("warrant") { return item.category == .warranties }
            return [item.title, item.source, item.summary, item.suggestedAction, item.category.rawValue].joined(separator: " ").localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        List(results) { item in NavigationLink(value: item) { ActionRow(item: item) }.listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16)).listRowSeparator(.hidden) }
            .listStyle(.plain).navigationTitle("search.title")
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "search.prompt")
            .navigationDestination(for: AdminItem.self) { ItemDetailView(itemID: $0.id) }
            .overlay { if query.isEmpty { ContentUnavailableView("search.empty.title", systemImage: "text.magnifyingglass", description: Text("search.empty.body")) } else if results.isEmpty { ContentUnavailableView.search(text: query) } }
    }
}

