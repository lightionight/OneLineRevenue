import SwiftUI

struct AssetsView: View {
    @EnvironmentObject private var model: AppViewModel
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    RenderDetailView(pack: model.latestPack)
                    Button {
                        model.exportLatestPack()
                        showShareSheet = true
                    } label: {
                        Label("Export full asset pack", systemImage: "square.and.arrow.up.fill")
                            .font(.headline.weight(.black))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.ink)
                    TestResultEditor()
                }
                .padding(18)
            }
            .background(Theme.paper.ignoresSafeArea())
            .navigationTitle("Assets")
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [ExportService.makeShareText(for: model.latestPack)])
            }
        }
    }
}

struct RenderDetailView: View {
    let pack: RevenueAssetPack

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            videoHero
            scoreCard
            playbookCard
            timeline
            copyPack
            versionBCard
            promptPack
        }
    }

    private var videoHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("5s")
                    .font(.caption.weight(.black))
                    .foregroundStyle(Theme.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Theme.gold)
                    .clipShape(Capsule())
                Text(pack.status.rawValue)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                Image(systemName: "play.fill")
                    .font(.title2.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(.white.opacity(0.16))
                    .clipShape(Circle())
            }
            Spacer(minLength: 70)
            Text(pack.headline)
                .font(.system(size: 34, weight: .black, design: .rounded))
                .lineSpacing(-3)
                .foregroundStyle(.white)
            Text(pack.videoConcept)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding(24)
        .frame(minHeight: 330)
        .background(Theme.hero)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "Video structure",
                title: "5-second sales timeline",
                subtitle: "Each second has a job: stop, prove, convert."
            )
            ForEach(pack.timeline) { beat in
                HStack(alignment: .top, spacing: 12) {
                    Text(beat.time)
                        .font(.caption.weight(.black))
                        .foregroundStyle(.white)
                        .frame(width: 54)
                        .padding(.vertical, 8)
                        .background(Theme.ink)
                        .clipShape(Capsule())
                    VStack(alignment: .leading, spacing: 4) {
                        Text(beat.line)
                            .font(.subheadline.weight(.black))
                        Text(beat.visual)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(14)
                .background(.white.opacity(0.74))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .revenueCard()
    }

    private var scoreCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "Money score",
                title: "\(pack.score.total)/100 revenue readiness",
                subtitle: "A quick scoring system for whether this asset is likely to earn another test."
            )
            scoreRow("Hook strength", pack.score.hookStrength)
            scoreRow("Proof strength", pack.score.proofStrength)
            scoreRow("Offer clarity", pack.score.offerClarity)
            scoreRow("Platform fit", pack.score.platformFit)
            scoreRow("Repeat potential", pack.score.repeatPotential)
        }
        .revenueCard()
    }

    private func scoreRow(_ title: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption.weight(.black))
                Spacer()
                Text("\(value)")
                    .font(.caption.weight(.black))
                    .foregroundStyle(Theme.flame)
            }
            ProgressView(value: Double(value), total: 100)
                .tint(value >= 82 ? Theme.mint : Theme.flame)
        }
    }

    private var playbookCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "Category playbook",
                title: "\(pack.playbook.category.rawValue) selling pattern",
                subtitle: "Category-specific tactics make the output feel less generic."
            )
            CopyLine(title: "Winning pattern", body: pack.playbook.winningPattern)
            CopyLine(title: "Proof moment", body: pack.playbook.proofMoment)
            CopyLine(title: "Trust builder", body: pack.playbook.trustBuilder)
        }
        .revenueCard()
    }

    private var copyPack: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "Revenue asset pack",
                title: "Ready-to-use selling copy",
                subtitle: "Hook, offer, CTA, captions, landing copy, and follow-up."
            )
            ForEach(pack.copies) { item in
                CopyLine(title: item.title, body: item.body)
            }
        }
        .revenueCard()
    }

    private var promptPack: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "JiMeng ready",
                title: "Video prompt",
                subtitle: "This prompt is ready to connect to the JiMeng CLI render pipeline."
            )
            CopyLine(title: "Positive prompt", body: pack.prompt.positive)
            CopyLine(title: "Negative prompt", body: pack.prompt.negative)
        }
        .revenueCard()
    }

    private var versionBCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "Repurchase engine",
                title: pack.versionBPlan.title,
                subtitle: "The best monetization path is not one render. It is the next smarter render."
            )
            CopyLine(title: "Keep", body: pack.versionBPlan.keep)
            CopyLine(title: "Change", body: pack.versionBPlan.change)
            CopyLine(title: "Why it can make money", body: pack.versionBPlan.whyItCanMakeMoney)
            CopyLine(title: "Recommended test budget", body: pack.versionBPlan.recommendedBudget)
        }
        .revenueCard()
    }
}

struct CopyLine: View {
    let title: String
    let body: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.caption.weight(.black))
                .foregroundStyle(Theme.flame)
            Text(body)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct TestResultEditor: View {
    @EnvironmentObject private var model: AppViewModel
    @State private var spend = "$10"
    @State private var clicks = "41"
    @State private var addToCarts = "7"
    @State private var orders = "2"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(
                eyebrow: "Learning loop",
                title: "Record the first test signal",
                subtitle: "This is what turns the app from generator into revenue coach."
            )
            HStack {
                field("Spend", text: $spend)
                field("Clicks", text: $clicks)
            }
            HStack {
                field("Carts", text: $addToCarts)
                field("Orders", text: $orders)
            }
            Button {
                let result = TestResult(
                    spend: spend,
                    clicks: clicks,
                    addToCarts: addToCarts,
                    orders: orders,
                    learning: learningText,
                    nextMove: nextMove
                )
                model.saveTestResult(result)
            } label: {
                Text("Save learning and next move")
                    .font(.headline.weight(.black))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.flame)

            if let result = model.latestPack.testResult {
                CopyLine(title: "Learning", body: result.learning)
                CopyLine(title: "Next move", body: result.nextMove)
            }
        }
        .revenueCard()
    }

    private var learningText: String {
        "The test produced \(clicks) clicks, \(addToCarts) add-to-carts, and \(orders) orders from \(spend) spend."
    }

    private var nextMove: String {
        if Int(orders) ?? 0 > 0 {
            return "Create Version B with the result shown in the first second and increase test budget carefully."
        }
        if Int(clicks) ?? 0 > 20 {
            return "Clicks exist but conversion is weak. Keep the hook, rewrite the offer, and add a stronger proof shot."
        }
        return "The hook did not stop enough people. Test a pain-first angle next."
    }

    private func field(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.black))
                .foregroundStyle(.secondary)
            TextField(title, text: text)
                .textFieldStyle(.roundedBorder)
        }
    }
}
