import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var model: AppViewModel
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    let onUnlock: () -> Void

    private var previewPack: RevenueAssetPack {
        if let angle = model.selectedAngle {
            return RevenueEngine.makeAssetPack(
                brief: model.currentBrief,
                angle: angle,
                version: model.projects.flatMap(\.packs).count + 1
            )
        }
        return model.latestPack
    }

    private var moneyPlan: MoneyPlan {
        GrowthStrategyEngine.moneyPlan(for: previewPack, balance: model.balance)
    }

    private var paywall: PaywallPlan {
        ConversionEngine.paywallPlan(for: previewPack, moneyPlan: moneyPlan, balance: model.balance)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    hero
                    valueStack
                    recommendedOffer
                    offerGrid
                    objections
                    unlockButton
                }
                .padding(18)
            }
            .background(Theme.paper.ignoresSafeArea())
            .navigationTitle("Unlock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("PAY ONLY WHEN THE SCAN FINDS AN ANGLE")
                .font(.caption.weight(.black))
                .foregroundStyle(Theme.gold)
            Text(paywall.headline)
                .font(.system(size: 38, weight: .black, design: .rounded))
                .lineSpacing(-3)
                .foregroundStyle(.white)
            Text(paywall.subheadline)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.76))
            CopyLine(title: "Why now", body: paywall.urgency)
        }
        .padding(24)
        .background(Theme.hero)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
    }

    private var valueStack: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "Value stack",
                title: "What this unlocks",
                subtitle: "Make the purchase feel concrete before asking for money."
            )
            ForEach(paywall.valueStack) { item in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Theme.mint)
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(item.title)
                                .font(.headline.weight(.black))
                            Spacer()
                            Text(item.value)
                                .font(.caption.weight(.black))
                                .foregroundStyle(Theme.flame)
                        }
                        Text(item.reason)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(14)
                .background(.white.opacity(0.76))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .revenueCard()
    }

    private var recommendedOffer: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "Recommended",
                title: paywall.recommendedOffer.title,
                subtitle: paywall.recommendedOffer.primaryReason
            )
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(paywall.recommendedOffer.badge)
                        .font(.caption.weight(.black))
                        .foregroundStyle(Theme.flame)
                    Text(paywall.recommendedOffer.price)
                        .font(.system(size: 48, weight: .black, design: .rounded))
                    Text(paywall.recommendedOffer.creditValue)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "flame.fill")
                    .font(.system(size: 42, weight: .black))
                    .foregroundStyle(Theme.flame)
            }
        }
        .revenueCard()
    }

    private var offerGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "Choose",
                title: "Render credit options",
                subtitle: "Single test first. Pack only when the product deserves iteration."
            )
            ForEach(paywall.offers) { offer in
                VStack(alignment: .leading, spacing: 8) {
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
                        Spacer()
                        Text(offer.price)
                            .font(.headline.weight(.black))
                            .foregroundStyle(Theme.flame)
                    }
                    Text(offer.primaryReason)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(offer.isRecommended ? Theme.gold.opacity(0.22) : .white.opacity(0.76))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .revenueCard()
    }

    private var objections: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "No pressure",
                title: "Common buying doubts",
                subtitle: "Answer objections before they become exits."
            )
            ForEach(paywall.objections) { item in
                CopyLine(title: item.objection, body: item.answer)
            }
        }
        .revenueCard()
    }

    private var unlockButton: some View {
        Button {
            onUnlock()
            dismiss()
        } label: {
            VStack(spacing: 4) {
                Text(ConversionEngine.checkoutCTA(for: previewPack, balance: model.balance))
                    .font(.headline.weight(.black))
                Text("No subscription required for single tests")
                    .font(.caption.weight(.bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.flame)
    }
}
