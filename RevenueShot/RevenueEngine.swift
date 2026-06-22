import Foundation

enum RevenueEngine {
    static func scan(brief: ProductBrief) -> RevenueScan {
        let product = brief.productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Uploaded Product" : brief.productName
        let pain = brief.problem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "The buyer does not understand the value fast enough." : brief.problem
        let buyer = brief.audience.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "US small-business shoppers" : brief.audience
        let platform = brief.platform.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "TikTok Shop" : brief.platform
        let category = GrowthStrategyEngine.detectCategory(from: brief)
        let playbook = GrowthStrategyEngine.playbook(for: category)
        let angles = GrowthStrategyEngine.angles(for: brief, playbook: playbook)

        return RevenueScan(
            productName: product,
            buyer: buyer,
            corePain: pain,
            buyingTrigger: trigger(for: brief.goal),
            trustBarrier: playbook.trustBuilder,
            bestPlatform: platform,
            confidence: GrowthStrategyEngine.score(brief: brief, angle: angles.first!, playbook: playbook).total,
            angles: angles
        )
    }

    static func makeAssetPack(brief: ProductBrief, angle: SalesAngle, version: Int) -> RevenueAssetPack {
        let product = brief.productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Uploaded Product" : brief.productName
        let headline = headlineFor(product: product, angle: angle)
        let offer = offerFor(product: product, problem: brief.problem, angle: angle)
        let cta = ctaFor(goal: brief.goal)
        let category = GrowthStrategyEngine.detectCategory(from: brief)
        let playbook = GrowthStrategyEngine.playbook(for: category)
        let score = GrowthStrategyEngine.score(brief: brief, angle: angle, playbook: playbook)
        let versionB = GrowthStrategyEngine.versionBPlan(
            for: RevenueAssetPack(
                productName: product,
                angle: angle,
                cost: AppConfig.renderCost,
                status: .draft,
                createdAt: Date(),
                headline: headline,
                offer: offer,
                cta: cta,
                videoConcept: "",
                timeline: [],
                copies: [],
                prompt: PromptPack(positive: "", negative: ""),
                score: score,
                versionBPlan: VersionBPlan(title: "", keep: "", change: "", whyItCanMakeMoney: "", recommendedBudget: ""),
                playbook: playbook,
                testResult: nil
            ),
            result: nil
        )

        return RevenueAssetPack(
            productName: product,
            angle: angle,
            cost: AppConfig.renderCost,
            status: .ready,
            createdAt: Date(),
            headline: headline,
            offer: offer,
            cta: cta,
            videoConcept: "\(playbook.winningPattern) Built around \(angle.title.lowercased()).",
            timeline: [
                TimelineBeat(time: "0-1s", line: angle.hook, visual: "Tight product or problem close-up with bold captions."),
                TimelineBeat(time: "1-3s", line: offer, visual: playbook.proofMoment),
                TimelineBeat(time: "3-5s", line: cta, visual: "Result shot, price/value cue, and simple call to action.")
            ],
            copies: [
                AssetCopy(title: "Hook (opening line)", body: angle.hook),
                AssetCopy(title: "Offer (why to buy)", body: offer),
                AssetCopy(title: "CTA (call to action)", body: cta),
                AssetCopy(title: "TikTok caption", body: "\(product) sales test V\(version): \(angle.title)."),
                AssetCopy(title: "Instagram caption", body: "A tiny product test for a very real problem: \(brief.problem)"),
                AssetCopy(title: "Facebook ad copy", body: "If \(brief.problem.lowercased()), this is the 5-second product test worth watching."),
                AssetCopy(title: "Landing hero", body: headline),
                AssetCopy(title: "DM follow-up", body: "If this is the problem you are trying to solve, start with this version before buying more."),
                AssetCopy(title: "Repurchase trigger", body: angle.repurchaseTrigger)
            ],
            prompt: PromptPack(
                positive: "Create a 5-second vertical short-form commerce video for \(product). Category: \(category.rawValue). Audience: \(brief.audience). Platform: \(brief.platform). Angle: \(angle.title). Winning pattern: \(playbook.winningPattern). Proof moment: \(playbook.proofMoment). Structure: 0-1s hook, 1-3s product proof, 3-5s result and CTA. UGC style, real product close-up, clear subtitles, high conversion energy.",
                negative: "No watermark, no fake app UI, no unreadable text, no distorted hands, no unrealistic product claims, no celebrity likeness."
            ),
            score: score,
            versionBPlan: versionB,
            playbook: playbook,
            testResult: nil
        )
    }

    private static func trigger(for goal: RevenueGoal) -> String {
        switch goal {
        case .growSales: return "The user wants a fast ad angle that can turn attention into orders."
        case .testSideIncome: return "The user wants to know if this product can become a repeatable income stream."
        case .validateMarket: return "The user wants evidence before buying inventory or spending more."
        }
    }

    private static func headlineFor(product: String, angle: SalesAngle) -> String {
        "\(product): \(angle.title)"
    }

    private static func offerFor(product: String, problem: String, angle: SalesAngle) -> String {
        "\(product) helps solve this: \(problem)"
    }

    private static func ctaFor(goal: RevenueGoal) -> String {
        switch goal {
        case .growSales: return "Run this test today and watch the first signal."
        case .testSideIncome: return "Test this angle before you buy more inventory."
        case .validateMarket: return "Use the result to decide whether this product deserves budget."
        }
    }
}
