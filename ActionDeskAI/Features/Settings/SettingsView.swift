import SwiftUI

struct SettingsView: View {
    @Environment(AppStore.self) private var store
    @Environment(PurchaseService.self) private var purchases
    @AppStorage("privacyLockEnabled") private var privacyLockEnabled = false
    @AppStorage("hideSensitiveContent") private var hideSensitiveContent = false
    @AppStorage("autoLockMinutes") private var autoLockMinutes = 1
    @State private var confirmDelete = false
    let onShowPaywall: () -> Void

    var body: some View {
        Form {
            Section("settings.plan") {
                Button(action: onShowPaywall) { HStack { Label(purchases.hasPro ? "settings.pro.active" : "settings.pro.upgrade", systemImage: "sparkles"); Spacer(); Image(systemName: "chevron.right").foregroundStyle(.tertiary) } }.foregroundStyle(.primary)
            }
            Section("settings.privacy") {
                Toggle("settings.privacyLock", isOn: $privacyLockEnabled)
                Toggle("settings.hideSensitive", isOn: $hideSensitiveContent)
                Picker("settings.autoLock", selection: $autoLockMinutes) { Text("settings.autoLock.immediate").tag(0); Text("settings.autoLock.one").tag(1); Text("settings.autoLock.five").tag(5) }
                NavigationLink("settings.processing") { ProcessingDisclosureView() }
            }
            Section("settings.data") {
                Button("settings.export") {}
                Button("settings.deleteAIHistory") {}
                Button("settings.deleteAll", role: .destructive) { confirmDelete = true }
            }
            Section("settings.about") {
                Link("settings.privacyPolicy", destination: URL(string: "https://example.com/privacy")!)
                Link("settings.terms", destination: URL(string: "https://example.com/terms")!)
                LabeledContent("settings.version", value: "1.0")
            }
        }.navigationTitle("settings.title")
            .confirmationDialog("settings.delete.confirm", isPresented: $confirmDelete, titleVisibility: .visible) { Button("settings.deleteAll", role: .destructive) { Task { await store.deleteAll() } }; Button("action.cancel", role: .cancel) {} } message: { Text("settings.delete.warning") }
    }
}

private struct ProcessingDisclosureView: View {
    var body: some View { List { Section("privacy.onDevice") { Label("privacy.localStorage", systemImage: "iphone.and.arrow.forward"); Label("privacy.previewAnalysis", systemImage: "lock") }; Section("privacy.external") { Text("privacy.external.body") }; Section("privacy.verify") { Text("privacy.verify.body") } }.navigationTitle("settings.processing") }
}

