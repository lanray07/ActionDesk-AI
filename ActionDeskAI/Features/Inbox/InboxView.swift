import SwiftUI

struct InboxView: View {
    @Environment(AppStore.self) private var store
    let onCapture: () -> Void

    private var activeItems: [AdminItem] { store.items.filter { ![.resolved, .archived].contains($0.status) } }
    private var urgent: [AdminItem] { activeItems.filter { $0.priority == .urgent } }
    private var dueSoon: [AdminItem] { activeItems.filter { $0.priority == .dueSoon } }
    private var waiting: [AdminItem] { activeItems.filter { $0.status == .waiting } }
    private var upcoming: [AdminItem] { activeItems.filter { $0.priority == .upcoming } }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 22) {
                greeting
                summaryStrip
                if !urgent.isEmpty { itemSection("section.urgent", items: urgent, color: ADColor.urgent) }
                if !dueSoon.isEmpty { itemSection("section.dueSoon", items: dueSoon, color: ADColor.warning) }
                if !waiting.isEmpty { itemSection("section.waiting", items: waiting, color: ADColor.calm) }
                if !upcoming.isEmpty { itemSection("section.upcoming", items: upcoming, color: ADColor.accent) }
                if activeItems.isEmpty { ContentUnavailableView("inbox.empty.title", systemImage: "checkmark.circle", description: Text("inbox.empty.body")) }
            }
            .padding(16).padding(.bottom, 72)
        }
        .background(ADColor.background)
        .navigationTitle("inbox.title")
        .toolbar { ToolbarItem(placement: .primaryAction) { Button(action: onCapture) { Image(systemName: "plus").fontWeight(.semibold) }.accessibilityLabel("capture.title") } }
        .overlay(alignment: .bottomTrailing) {
            Button(action: onCapture) { Label("capture.scan", systemImage: "viewfinder").font(.headline).padding(.horizontal, 18).padding(.vertical, 13) }
                .buttonStyle(.borderedProminent).buttonBorderShape(.capsule).padding(18).shadow(color: .black.opacity(0.14), radius: 12, y: 5)
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("dashboard.greeting").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary).textCase(.uppercase)
            Text("dashboard.headline").font(.largeTitle.bold()).tracking(-0.6)
            Text("dashboard.subtitle").font(.body).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private var summaryStrip: some View {
        HStack(spacing: 0) {
            SummaryMetric(value: "\(activeItems.count)", label: "dashboard.actions")
            Divider().frame(height: 42)
            SummaryMetric(value: "\(dueSoon.count + urgent.count)", label: "dashboard.deadlines")
            Divider().frame(height: 42)
            SummaryMetric(value: "\(waiting.count)", label: "dashboard.waiting")
        }.padding(.vertical, 14).background(ADColor.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func itemSection(_ title: LocalizedStringKey, items: [AdminItem], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { Circle().fill(color).frame(width: 8, height: 8); Text(title).font(.headline); Spacer(); Text("\(items.count)").foregroundStyle(.secondary) }
            ForEach(items) { item in NavigationLink(value: item) { ActionRow(item: item) }.buttonStyle(.plain) }
        }.navigationDestination(for: AdminItem.self) { ItemDetailView(itemID: $0.id) }
    }
}

private struct SummaryMetric: View {
    let value: String; let label: LocalizedStringKey
    var body: some View { VStack(spacing: 2) { Text(value).font(.title2.bold()).monospacedDigit(); Text(label).font(.caption).foregroundStyle(.secondary).lineLimit(1).minimumScaleFactor(0.75) }.frame(maxWidth: .infinity) }
}

struct ActionRow: View {
    let item: AdminItem
    var body: some View {
        ADCard {
            HStack(alignment: .top, spacing: 13) {
                Image(systemName: item.category.symbol).font(.title3).foregroundStyle(item.status.color).frame(width: 38, height: 38).background(item.status.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 6) {
                    HStack { Text(item.title).font(.headline).foregroundStyle(.primary); Spacer(); StatusPill(status: item.status) }
                    Text(item.source).font(.subheadline).foregroundStyle(.secondary)
                    if let deadline = item.deadline { Label { Text(deadline, format: .dateTime.day().month(.abbreviated)) } icon: { Image(systemName: "calendar") }.font(.caption.weight(.medium)).foregroundStyle(item.priority == .urgent ? ADColor.urgent : .secondary) }
                    Text(item.suggestedAction).font(.subheadline).foregroundStyle(.primary).lineLimit(2)
                }
                Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.tertiary).padding(.top, 9)
            }
        }
        .swipeActions(edge: .leading) { Button { } label: { Label("action.complete", systemImage: "checkmark") }.tint(ADColor.accent) }
    }
}

extension DocumentCategory {
    var symbol: String {
        switch self { case .bills: "bolt.fill"; case .subscriptions: "repeat"; case .insurance: "shield"; case .receipts: "receipt"; case .warranties: "checkmark.seal"; case .returns: "shippingbox.and.arrow.backward"; case .appointments: "calendar"; case .contracts: "signature"; case .government: "building.columns"; case .health: "cross.case"; case .other: "doc.text" }
    }
}

