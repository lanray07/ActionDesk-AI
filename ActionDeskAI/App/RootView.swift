import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("privacyLockEnabled") private var privacyLockEnabled = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: AppTab = .inbox
    @State private var presentedSheet: SheetDestination?
    @State private var isUnlocked = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView { hasCompletedOnboarding = true }
            } else if privacyLockEnabled && !isUnlocked {
                PrivacyLockView { isUnlocked = true }
            } else {
                appShell
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active, privacyLockEnabled { isUnlocked = false }
        }
    }

    private var appShell: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { InboxView(onCapture: { presentedSheet = .capture }) }
                .tabItem { Label(AppTab.inbox.title, systemImage: AppTab.inbox.symbol) }.tag(AppTab.inbox)
            NavigationStack { DocumentsView(onCapture: { presentedSheet = .capture }) }
                .tabItem { Label(AppTab.documents.title, systemImage: AppTab.documents.symbol) }.tag(AppTab.documents)
            NavigationStack { AssistantView() }
                .tabItem { Label(AppTab.assistant.title, systemImage: AppTab.assistant.symbol) }.tag(AppTab.assistant)
            NavigationStack { SearchView() }
                .tabItem { Label(AppTab.search.title, systemImage: AppTab.search.symbol) }.tag(AppTab.search)
            NavigationStack { SettingsView(onShowPaywall: { presentedSheet = .paywall }) }
                .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.symbol) }.tag(AppTab.settings)
        }
        .sheet(item: $presentedSheet) { destination in
            switch destination {
            case .capture: CaptureView()
            case .paywall: PaywallView()
            }
        }
    }
}

