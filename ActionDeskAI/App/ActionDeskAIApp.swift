import SwiftUI

@main
struct ActionDeskAIApp: App {
    @State private var store = AppStore()
    @State private var purchases = PurchaseService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(purchases)
                .tint(ADColor.accent)
                .task { await store.load() }
                .task { await purchases.start() }
        }
    }
}

