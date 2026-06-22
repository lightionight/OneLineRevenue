import SwiftUI

struct RootView: View {
    @EnvironmentObject private var model: AppViewModel

    var body: some View {
        TabView {
            GenerateView()
                .tabItem { Label("Shot", systemImage: "bolt.fill") }
            AssetsView()
                .tabItem { Label("Assets", systemImage: "play.rectangle.fill") }
            MoneyView()
                .tabItem { Label("Money", systemImage: "dollarsign.circle.fill") }
            ProjectsView()
                .tabItem { Label("Tests", systemImage: "chart.xyaxis.line") }
            WalletView()
                .tabItem { Label("Wallet", systemImage: "creditcard.fill") }
        }
        .tint(Theme.flame)
        .alert("Revenue Shot", isPresented: Binding(
            get: { model.errorMessage != nil },
            set: { if !$0 { model.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}
