import Foundation
import Combine
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published var isLoadingProducts = false
    @Published var purchaseError: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = listenForTransactions()
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            products = try await Product.products(for: AppConfig.ProductID.all)
                .sorted { $0.displayPrice < $1.displayPrice }
            await refreshPurchasedProducts()
        } catch {
            purchaseError = "Could not load App Store products: \(error.localizedDescription)"
        }
    }

    func purchase(_ product: Product) async -> Double {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                purchasedProductIDs.insert(transaction.productID)
                return AppConfig.credits(for: transaction.productID)
            case .userCancelled, .pending:
                return 0
            @unknown default:
                return 0
            }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
            return 0
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshPurchasedProducts()
        } catch {
            purchaseError = "Restore failed: \(error.localizedDescription)"
        }
    }

    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    private func refreshPurchasedProducts() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                purchased.insert(transaction.productID)
            }
        }
        purchasedProductIDs = purchased
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                if let transaction = try? checkVerified(result) {
                    purchasedProductIDs.insert(transaction.productID)
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum PurchaseError: Error {
    case failedVerification
}
