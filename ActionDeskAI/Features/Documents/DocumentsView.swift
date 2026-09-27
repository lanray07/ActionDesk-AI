import SwiftUI

struct DocumentsView: View {
    @Environment(AppStore.self) private var store
    let onCapture: () -> Void
    @State private var category: DocumentCategory?

    private var items: [AdminItem] { category.map { selected in store.items.filter { $0.category == selected } } ?? store.items }

    var body: some View {
        List {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack { FilterChip(title: "filter.all", selected: category == nil) { category = nil }; ForEach(DocumentCategory.allCases, id: \.self) { value in FilterChip(title: LocalizedStringKey("category.\(value.rawValue)"), selected: category == value) { category = value } } }.padding(.vertical, 4)
                }.listRowInsets(.init(top: 4, leading: 16, bottom: 4, trailing: 0)).listRowBackground(Color.clear)
            }
            ForEach(items.sorted { $0.createdAt > $1.createdAt }) { item in
                NavigationLink(value: item) {
                    HStack(spacing: 13) {
                        Image(systemName: item.category.symbol).foregroundStyle(ADColor.accent).frame(width: 34, height: 34).background(ADColor.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 9))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.title).font(.headline)
                            Text(item.source).font(.subheadline).foregroundStyle(.secondary)
                            Text(item.createdAt, format: .dateTime.day().month(.abbreviated).year()).font(.caption).foregroundStyle(.tertiary)
                        }
                        Spacer()
                        StatusPill(status: item.status)
                    }.padding(.vertical, 5)
                }
            }
        }
        .listStyle(.insetGrouped).navigationTitle("documents.title")
        .toolbar { Button(action: onCapture) { Image(systemName: "plus") }.accessibilityLabel("capture.title") }
        .navigationDestination(for: AdminItem.self) { ItemDetailView(itemID: $0.id) }
        .overlay { if items.isEmpty { ContentUnavailableView("documents.empty.title", systemImage: "doc", description: Text("documents.empty.body")) } }
    }
}

private struct FilterChip: View {
    let title: LocalizedStringKey; let selected: Bool; let action: () -> Void
    var body: some View { Button(action: action) { Text(title).font(.subheadline.weight(.semibold)).padding(.horizontal, 12).padding(.vertical, 7).foregroundStyle(selected ? Color.white : Color.primary).background(selected ? ADColor.accent : ADColor.surface, in: Capsule()) }.buttonStyle(.plain) }
}

