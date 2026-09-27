import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PurchaseService.self) private var purchases

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Image(systemName: "sparkles.rectangle.stack.fill").font(.system(size: 54)).foregroundStyle(ADColor.accent)
                    VStack(spacing: 8) { Text("paywall.title").font(.largeTitle.bold()); Text("paywall.subtitle").foregroundStyle(.secondary).multilineTextAlignment(.center) }
                    ADCard { VStack(alignment: .leading, spacing: 14) { ProFeature("paywall.feature.analysis", "doc.text.magnifyingglass"); ProFeature("paywall.feature.voice", "waveform"); ProFeature("paywall.feature.tracking", "checklist"); ProFeature("paywall.feature.search", "magnifyingglass") } }
                    if purchases.products.isEmpty { Text("paywall.unavailable").font(.footnote).foregroundStyle(.secondary) }
                    ForEach(purchases.products) { product in Button { Task { await purchases.purchase(product) } } label: { HStack { VStack(alignment: .leading) { Text(product.displayName).font(.headline); Text(product.description).font(.caption).foregroundStyle(.secondary) }; Spacer(); Text(product.displayPrice).font(.headline) }.padding(16).background(ADColor.surface, in: RoundedRectangle(cornerRadius: 16)) }.buttonStyle(.plain) }
                    Button("paywall.restore") { Task { await purchases.restore() } }
                    Text("paywall.legal").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }.padding(20)
            }.background(ADColor.background).toolbar { ToolbarItem(placement: .cancellationAction) { Button("action.close") { dismiss() } } }
        }
    }
}

private struct ProFeature: View { let title: LocalizedStringKey; let symbol: String; init(_ title: LocalizedStringKey, _ symbol: String) { self.title = title; self.symbol = symbol }; var body: some View { Label(title, systemImage: symbol).font(.headline) } }

