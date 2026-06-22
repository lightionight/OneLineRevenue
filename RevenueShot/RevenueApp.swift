import SwiftUI

@main
struct RevenueApp: App {
    @StateObject private var viewModel = AppViewModel()
    @StateObject private var purchaseManager = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel)
                .environmentObject(purchaseManager)
                .task {
                    await purchaseManager.loadProducts()
                }
        }
    }
}
