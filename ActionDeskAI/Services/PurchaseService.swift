import StoreKit
import Observation

@MainActor @Observable
final class PurchaseService {
    var products: [Product] = []
    var hasPro = false
    var errorMessage: String?
    private let productIDs = ["com.actiondesk.lifeadmin.pro.monthly", "com.actiondesk.lifeadmin.pro.annual"]

    func start() async {
        do { products = try await Product.products(for: productIDs); await refreshEntitlements() }
        catch { errorMessage = error.localizedDescription }
        Task { for await _ in Transaction.updates { await self.refreshEntitlements() } }
    }
    func purchase(_ product: Product) async {
        do {
            if case .success(let verification) = try await product.purchase(), case .verified(let transaction) = verification { await transaction.finish(); await refreshEntitlements() }
        } catch { errorMessage = error.localizedDescription }
    }
    func restore() async { try? await StoreKit.AppStore.sync(); await refreshEntitlements() }
    private func refreshEntitlements() async {
        hasPro = false
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement, productIDs.contains(transaction.productID), transaction.revocationDate == nil { hasPro = true }
        }
    }
}
