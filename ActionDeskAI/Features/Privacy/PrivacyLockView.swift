import SwiftUI

struct PrivacyLockView: View {
    let onUnlock: () -> Void
    @State private var isChecking = false
    @State private var failed = false
    var body: some View {
        VStack(spacing: 22) { Spacer(); Image(systemName: "lock.shield.fill").font(.system(size: 64)).foregroundStyle(ADColor.accent); Text("privacy.lock.title").font(.largeTitle.bold()); Text("privacy.lock.body").foregroundStyle(.secondary).multilineTextAlignment(.center); if failed { Text("privacy.lock.failed").font(.footnote).foregroundStyle(ADColor.urgent) }; Spacer(); Button { authenticate() } label: { if isChecking { ProgressView().frame(maxWidth: .infinity) } else { Label("privacy.unlock", systemImage: "faceid").frame(maxWidth: .infinity) } }.buttonStyle(.borderedProminent).controlSize(.large).disabled(isChecking) }.padding(28).background(ADColor.background.ignoresSafeArea()).task { authenticate() }
    }
    private func authenticate() { isChecking = true; Task { let success = await BiometricService.unlock(); isChecking = false; failed = !success; if success { onUnlock() } } }
}
