import SwiftUI

struct MoneyView: View {
    @EnvironmentObject private var model: AppViewModel

    private var plan: MoneyPlan {
        GrowthStrategyEngine.moneyPlan(for: model.latestPack, balance: model.balance)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    hero
                    forecastCard
                    recommendationCard
                    experimentRoadmap
                    retentionCard
                }
                .padding(18)
            }
            .background(Theme.paper.ignoresSafeArea())
            .navigationTitle("Money")
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Money Plan")
                .font(.caption.weight(.black))
                .foregroundStyle(.white.opacity(0.7))
            Text("What should this product test next?")
                .font(.system(size: 38, weight: .black, design: .rounded))
                .lineSpacing(-3)
                .foregroundStyle(.white)
            Text(model.latestPack.productName)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white.opacity(0.76))
            HStack {
                MetricPill(label: "SCORE", value: "\(model.latestPack.score.total)")
                MetricPill(label: "PACK", value: model.latestPack.costLabel)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(Theme.hero)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
    }

    private var forecastCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "Forecast",
                title: "First test planning estimate",
                subtitle: "A merchant needs a spending plan, not just a file."
            )
            HStack(spacing: 10) {
                moneyMetric("Budget", plan.forecast.testBudget)
                moneyMetric("Clicks", plan.forecast.expectedClicks)
                moneyMetric("Orders", plan.forecast.expectedOrders)
            }
            CopyLine(title: "Break-even order value", body: plan.forecast.breakEvenOrderValue)
            CopyLine(title: "Confidence note", body: plan.forecast.confidenceNote)
        }
        .revenueCard()
    }

    private func moneyMetric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.caption2.weight(.black))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.weight(.black))
                .foregroundStyle(Theme.ink)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.white.opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var recommendationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "Monetization",
                title: plan.creditRecommendation.title,
                subtitle: "The app should recommend the smallest useful purchase."
            )
            HStack {
                Text(plan.creditRecommendation.price)
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.flame)
                Spacer()
                Image(systemName: "cart.fill.badge.plus")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(Theme.ink)
            }
            CopyLine(title: "Reason", body: plan.creditRecommendation.reason)
            CopyLine(title: "Best for", body: plan.creditRecommendation.bestFor)
        }
        .revenueCard()
    }

    private var experimentRoadmap: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "Roadmap",
                title: "3-step revenue experiment",
                subtitle: "This turns one render into a sequence of paid tests."
            )
            ForEach(Array(plan.steps.enumerated()), id: \.element.id) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(Theme.flame)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 7) {
                        Text(step.title)
                            .font(.headline.weight(.black))
                        Text(step.action)
                            .font(.subheadline.weight(.semibold))
                        Text("Signal: \(step.successSignal)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        Text("If it wins: \(step.nextIfWins)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Theme.flame)
                    }
                    Spacer()
                }
                .padding(14)
                .background(.white.opacity(0.76))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .revenueCard()
    }

    private var retentionCard: some View {
        CopyLine(title: "Retention hook", body: plan.retentionHook)
            .revenueCard()
    }
}
