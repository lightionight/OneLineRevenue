import Foundation

enum GrowthStrategyEngine {
    static func detectCategory(from brief: ProductBrief) -> ProductCategory {
        let text = "\(brief.productName) \(brief.problem)".lowercased()
        if text.contains("curl") || text.contains("hair") || text.contains("skin") || text.contains("beauty") {
            return .beauty
        }
        if text.contains("clean") || text.contains("kitchen") || text.contains("pan") || text.contains("cloth") {
            return .kitchen
        }
        if text.contains("dog") || text.contains("cat") || text.contains("pet") || text.contains("paw") {
            return .pet
        }
        if text.contains("home") || text.contains("room") || text.contains("decor") {
            return .home
        }
        if text.contains("gym") || text.contains("fitness") || text.contains("workout") {
            return .fitness
        }
        return brief.category
    }

    static func playbook(for category: ProductCategory) -> CategoryPlaybook {
        switch category {
        case .beauty:
            return CategoryPlaybook(
                category: .beauty,
                winningPattern: "Before/after transformation with a believable routine.",
                proofMoment: "Show the final look early, then show the simple routine.",
                trustBuilder: "Use natural lighting, real skin/hair texture, and avoid miracle claims.",
                bestFirstAngles: [.proof, .time, .identity]
            )
        case .kitchen:
            return CategoryPlaybook(
                category: .kitchen,
                winningPattern: "Satisfying problem-to-clean transformation.",
                proofMoment: "One wipe, one cut, one pour, or one visible before/after.",
                trustBuilder: "Show an ordinary kitchen and a result that does not look fake.",
                bestFirstAngles: [.proof, .pain, .time]
            )
        case .pet:
            return CategoryPlaybook(
                category: .pet,
                winningPattern: "Owner problem plus pet comfort.",
                proofMoment: "Show the messy or stressful moment, then the calmer result.",
                trustBuilder: "Make the pet look safe, comfortable, and not forced.",
                bestFirstAngles: [.pain, .proof, .gift]
            )
        case .home:
            return CategoryPlaybook(
                category: .home,
                winningPattern: "Small upgrade that makes the room feel better.",
                proofMoment: "Show the before room feeling and the after mood shift.",
                trustBuilder: "Use real home lighting and avoid luxury overproduction.",
                bestFirstAngles: [.identity, .proof, .gift]
            )
        case .fitness:
            return CategoryPlaybook(
                category: .fitness,
                winningPattern: "Quick form, comfort, or consistency improvement.",
                proofMoment: "Show one motion feeling easier or more repeatable.",
                trustBuilder: "Avoid medical claims; focus on routine and consistency.",
                bestFirstAngles: [.pain, .time, .identity]
            )
        case .general:
            return CategoryPlaybook(
                category: .general,
                winningPattern: "Clear problem, visible proof, simple CTA.",
                proofMoment: "Show the product solving one specific moment.",
                trustBuilder: "Make the result concrete and believable.",
                bestFirstAngles: [.proof, .pain, .time]
            )
        }
    }

    static func angles(for brief: ProductBrief, playbook: CategoryPlaybook) -> [SalesAngle] {
        playbook.bestFirstAngles.map { angleType in
            angle(for: angleType, brief: brief, playbook: playbook)
        }
    }

    static func score(brief: ProductBrief, angle: SalesAngle, playbook: CategoryPlaybook) -> RevenueScore {
        let problemSpecificity = min(100, max(55, brief.problem.count * 2))
        let platformFit = brief.platform.lowercased().contains("tiktok") ? 90 : 76
        let proofStrength = angle.type == .proof ? 90 : playbook.bestFirstAngles.contains(.proof) ? 82 : 74
        let repeatPotential = angle.type == .time || angle.type == .proof ? 86 : 78

        return RevenueScore(
            hookStrength: angle.hook.count > 24 ? 84 : 76,
            proofStrength: proofStrength,
            offerClarity: problemSpecificity,
            platformFit: platformFit,
            repeatPotential: repeatPotential
        )
    }

    static func versionBPlan(for pack: RevenueAssetPack, result: TestResult?) -> VersionBPlan {
        guard let result else {
            return VersionBPlan(
                title: "Version B: proof-first test",
                keep: "Keep the core sales angle: \(pack.angle.title).",
                change: "Move the strongest visual proof into the first second.",
                whyItCanMakeMoney: "Most short-form ads fail before the buyer understands the result. Earlier proof can improve thumb-stop rate.",
                recommendedBudget: "$10-$20"
            )
        }

        let clicks = numeric(result.clicks)
        let orders = numeric(result.orders)
        let carts = numeric(result.addToCarts)

        if orders > 0 {
            return VersionBPlan(
                title: "Version B: scale the winner",
                keep: "Keep the hook and audience because the test already produced orders.",
                change: "Test a stronger first-second result shot and a clearer price/value cue.",
                whyItCanMakeMoney: "The angle has buying signal. Version B should improve conversion without changing the core message.",
                recommendedBudget: "$20-$50"
            )
        }
        if clicks >= 25 && carts == 0 {
            return VersionBPlan(
                title: "Version B: fix the offer",
                keep: "Keep the hook because people clicked.",
                change: "Rewrite the offer with clearer proof, guarantee, bundle, or price anchor.",
                whyItCanMakeMoney: "Attention exists, but purchase confidence is weak. The next render should reduce risk.",
                recommendedBudget: "$10-$20"
            )
        }
        return VersionBPlan(
            title: "Version B: new hook",
            keep: "Keep the product and audience.",
            change: "Switch to a sharper pain-first hook and show the product result sooner.",
            whyItCanMakeMoney: "The first test did not create enough attention. The next render should sell the problem before the product.",
            recommendedBudget: "$5-$10"
        )
    }

    static func moneyPlan(for pack: RevenueAssetPack, balance: Double) -> MoneyPlan {
        let score = pack.score.total
        let recommendedBudget = score >= 84 ? "$20" : "$10"
        let expectedClicks = score >= 84 ? "45-80" : "20-45"
        let expectedOrders = score >= 84 ? "1-4" : "0-2"
        let recommendation = creditRecommendation(for: pack, balance: balance)

        return MoneyPlan(
            forecast: RevenueForecast(
                testBudget: recommendedBudget,
                expectedClicks: expectedClicks,
                expectedOrders: expectedOrders,
                breakEvenOrderValue: score >= 84 ? "$8-$15" : "$15-$25",
                confidenceNote: "This is not a revenue guarantee. It is a planning estimate based on hook strength, proof strength, offer clarity, platform fit, and repeat potential."
            ),
            creditRecommendation: recommendation,
            steps: [
                ExperimentStep(
                    title: "Test A",
                    action: "Run the current asset with \(recommendedBudget) budget.",
                    successSignal: "CTR above 1.5% or at least one add-to-cart.",
                    nextIfWins: "Render Version B with the proof moment earlier."
                ),
                ExperimentStep(
                    title: "Version B",
                    action: pack.versionBPlan.change,
                    successSignal: "More clicks with same spend or stronger add-to-cart rate.",
                    nextIfWins: "Buy a 10-shot pack and test two adjacent angles."
                ),
                ExperimentStep(
                    title: "Scale or pivot",
                    action: "If orders appear, scale the winning angle. If not, switch category playbook angle.",
                    successSignal: "Order signal, comments asking where to buy, or saves/shares.",
                    nextIfWins: "Create a small campaign set: proof, pain, and gift angle."
                )
            ],
            retentionHook: "Your next render should not be random. It should be the next cheapest test that answers why people did or did not buy."
        )
    }

    private static func creditRecommendation(for pack: RevenueAssetPack, balance: Double) -> CreditRecommendation {
        if balance < AppConfig.renderCost {
            return CreditRecommendation(
                title: "Start with 1 Revenue Shot",
                price: "$0.99",
                reason: "You only need one paid render to validate whether this product has a usable first signal.",
                bestFor: "First-time users and unproven products"
            )
        }
        if pack.score.repeatPotential >= 84 {
            return CreditRecommendation(
                title: "Buy 10 Revenue Shots",
                price: "$6.99",
                reason: "This asset has enough repeat potential to test Version B, proof angle, and gift angle without overcommitting.",
                bestFor: "Products with early click or add-to-cart signal"
            )
        }
        return CreditRecommendation(
            title: "Use one more render first",
            price: "$0.99",
            reason: "The asset needs a sharper signal before a larger pack makes sense.",
            bestFor: "Products still searching for the right hook"
        )
    }

    private static func angle(for type: SalesAngleType, brief: ProductBrief, playbook: CategoryPlaybook) -> SalesAngle {
        switch type {
        case .proof:
            return SalesAngle(
                type: .proof,
                title: "\(playbook.proofMoment)",
                hook: "Watch this change in five seconds.",
                reason: "Proof reduces skepticism faster than a claim.",
                expectedSignal: "Look for thumb-stop rate, comments asking if it works, and add-to-carts.",
                repurchaseTrigger: "If clicks are strong, render Version B with the result shown first."
            )
        case .pain:
            return SalesAngle(
                type: .pain,
                title: "Name the exact annoying moment",
                hook: "If this sounds familiar: \(brief.problem)",
                reason: "A precise pain makes the buyer feel understood before the product appears.",
                expectedSignal: "Look for saves, shares, and comments repeating the pain.",
                repurchaseTrigger: "If engagement is high but orders are low, render Version B with a stronger offer."
            )
        case .gift:
            return SalesAngle(
                type: .gift,
                title: "Make it an easy gift decision",
                hook: "This is the kind of gift people actually use.",
                reason: "Gift framing lowers self-purchase hesitation and works well near seasonal moments.",
                expectedSignal: "Look for shares, saves, and comments tagging another person.",
                repurchaseTrigger: "If shares are strong, render a seasonal gift Version B."
            )
        case .time:
            return SalesAngle(
                type: .time,
                title: "Sell the time saved",
                hook: "What if this saved you 30 minutes this week?",
                reason: "Time is easier to understand than features, especially in short-form commerce.",
                expectedSignal: "Look for clicks from busy buyers and add-to-cart rate.",
                repurchaseTrigger: "If clicks are strong, render Version B with a faster before/after."
            )
        case .identity:
            return SalesAngle(
                type: .identity,
                title: "Sell the identity upgrade",
                hook: "This makes the whole routine feel more put together.",
                reason: "Some products sell because they help the buyer feel organized, stylish, or in control.",
                expectedSignal: "Look for saves, profile visits, and comments about lifestyle.",
                repurchaseTrigger: "If saves are high, render Version B with a lifestyle montage."
            )
        }
    }

    private static func numeric(_ value: String) -> Int {
        Int(value.filter(\.isNumber)) ?? 0
    }
}
