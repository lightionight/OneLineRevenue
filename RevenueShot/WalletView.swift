import SwiftUI

struct WalletView: View {
    @EnvironmentObject private var model: AppViewModel
    @EnvironmentObject private var purchases: PurchaseManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    walletHero
                    topUpCard
                    receiptList
                    iapNote
                }
                .padding(18)
            }
            .background(Theme.paper.ignoresSafeArea())
            .navigationTitle("Wallet")
            .alert("App Store Purchase", isPresented: Binding(
                get: { purchases.purchaseError != nil },
                set: { if !$0 { purchases.purchaseError = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(purchases.purchaseError ?? "")
            }
        }
    }

    private var walletHero: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Render Wallet")
                .font(.caption.weight(.black))
                .foregroundStyle(.white.opacity(0.7))
            Text(String(format: "$%.2f", model.balance))
                .font(.system(size: 58, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            HStack {
                MetricPill(label: "PRICE", value: "$0.50")
                MetricPill(label: "LEFT", value: "\(model.remainingRenders)")
            }
            Text("Low-friction credits are the first purchase strategy: users pay for a tiny revenue experiment, not a subscription promise.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(Theme.hero)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
    }

    private var topUpCard: some View {
        let moneyPlan = GrowthStrategyEngine.moneyPlan(for: model.latestPack, balance: model.balance)
        let paywall = ConversionEngine.paywallPlan(for: model.latestPack, moneyPlan: moneyPlan, balance: model.balance)
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(
                eyebrow: "Credits",
                title: "Buy the smallest useful pack",
                subtitle: "The best purchase is the one that funds the next experiment, not the biggest package."
            )
            CopyLine(title: "Recommended for this product", body: "\(paywall.recommendedOffer.title): \(paywall.recommendedOffer.primaryReason)")
            if purchases.products.isEmpty {
                VStack(spacing: 10) {
                    ForEach(paywall.offers) { offer in
                        simulatedOfferButton(offer)
                    }
                }
            } else {
                ForEach(purchases.products, id: \.id) { product in
                    Button {
                        Task {
                            let credits = await purchases.purchase(product)
                            if credits > 0 {
                                model.topUp(credits)
                            }
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.displayName)
                                    .font(.headline.weight(.black))
                                Text(product.description)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(product.displayPrice)
                                .font(.headline.weight(.black))
                                .foregroundStyle(Theme.flame)
                        }
                        .padding(14)
                        .background(.white.opacity(0.76))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                Button {
                    Task { await purchases.restorePurchases() }
                } label: {
                    Text("Restore purchases")
                        .font(.subheadline.weight(.black))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .revenueCard()
    }

    private func simulatedOfferButton(_ offer: PurchaseOffer) -> some View {
        Button {
            if offer.title.contains("50") {
                model.topUp(25)
            } else if offer.title.contains("10") {
                model.topUp(5)
            } else {
                model.topUp(0.5)
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(offer.title)
                            .font(.headline.weight(.black))
                        if offer.isRecommended {
                            Text("Recommended")
                                .font(.caption2.weight(.black))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(Theme.flame)
                                .clipShape(Capsule())
                        }
                    }
                    Text(offer.primaryReason)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text(offer.price)
                        .font(.headline.weight(.black))
                        .foregroundStyle(Theme.flame)
                    Text(offer.creditValue)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .background(offer.isRecommended ? Theme.gold.opacity(0.24) : .white.opacity(0.76))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var receiptList: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "Receipts",
                title: "Credit history",
                subtitle: "Top-ups, renders, and exports should all be traceable."
            )
            ForEach(model.receipts) { receipt in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(receipt.title)
                            .font(.subheadline.weight(.black))
                        Text(receipt.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(String(format: receipt.amount >= 0 ? "+$%.2f" : "-$%.2f", abs(receipt.amount)))
                        .font(.headline.weight(.black))
                        .foregroundStyle(receipt.amount >= 0 ? Theme.mint : Theme.flame)
                }
                .padding(14)
                .background(.white.opacity(0.76))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .revenueCard()
    }

    private var iapNote: some View {
        CopyLine(
            title: "App Store note",
            body: "For a real iOS launch, paid AI renders should be implemented with Apple IAP (In-App Purchase) consumable credits or subscriptions."
        )
        .revenueCard()
    }
}
