import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var page = 0
    private let pages: [OnboardingPage] = [
        .init(title: "onboarding.one.title", body: "onboarding.one.body", symbol: "tray.full.fill"),
        .init(title: "onboarding.two.title", body: "onboarding.two.body", symbol: "doc.viewfinder"),
        .init(title: "onboarding.three.title", body: "onboarding.three.body", symbol: "sparkles"),
        .init(title: "onboarding.four.title", body: "onboarding.four.body", symbol: "checkmark.circle.fill"),
        .init(title: "onboarding.five.title", body: "onboarding.five.body", symbol: "lock.shield.fill")
    ]

    var body: some View {
        VStack(spacing: 24) {
            TabView(selection: $page) { ForEach(Array(pages.enumerated()), id: \.offset) { index, item in VStack(spacing: 28) { Spacer(); Image(systemName: item.symbol).font(.system(size: 72)).foregroundStyle(ADColor.accent).symbolRenderingMode(.hierarchical); VStack(spacing: 14) { Text(item.title).font(.largeTitle.bold()).multilineTextAlignment(.center); Text(item.body).font(.title3).foregroundStyle(.secondary).multilineTextAlignment(.center).lineSpacing(4) }; Spacer() }.padding(30).tag(index) } }.tabViewStyle(.page(indexDisplayMode: .always))
            Button { if page == pages.count - 1 { onComplete() } else { withAnimation { page += 1 } } } label: { Text(LocalizedStringKey(page == pages.count - 1 ? "onboarding.start" : "onboarding.continue")).frame(maxWidth: .infinity) }.buttonStyle(.borderedProminent).controlSize(.large).padding(.horizontal, 24).padding(.bottom, 16)
        }.background(ADColor.background.ignoresSafeArea())
    }
}

private struct OnboardingPage { let title: LocalizedStringKey; let body: LocalizedStringKey; let symbol: String }

