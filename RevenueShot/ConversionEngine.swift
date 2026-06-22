import Foundation

enum ConversionEngine {
    static func paywallPlan(for pack: RevenueAssetPack, moneyPlan: MoneyPlan, balance: Double) -> PaywallPlan {
        let recommended = recommendedOffer(for: pack, moneyPlan: moneyPlan, balance: balance)
        let offers = [
            PurchaseOffer(
                title: "1 Revenue Shot",
                price: "$0.99",
                badge: "Start here",
                creditValue: "1 render",
                primaryReason: "Unlock one complete sales test without committing to a subscription.",
                cta: "Unlock this test",
                isRecommended: recommended.title == "1 Revenue Shot"
            ),
            PurchaseOffer(
                title: "10 Revenue Shots",
                price: "$6.99",
                badge: "Best first pack",
                creditValue: "10 renders",
                primaryReason: "Enough credits to test Version A, Version B, and two adjacent angles.",
                cta: "Buy 10-shot pack",
                isRecommended: recommended.title == "10 Revenue Shots"
            ),
            PurchaseOffer(
                title: "50 Revenue Shots",
                price: "$24.99",
                badge: "For operators",
                creditValue: "50 renders",
                primaryReason: "Built for sellers or agencies testing multiple products every week.",
                cta: "Scale testing",
                isRecommended: recommended.title == "50 Revenue Shots"
            )
        ]

        return PaywallPlan(
            headline: "Unlock the full sales test for \(pack.costLabel)",
            subheadline: "Your free scan found the angle. The paid render gives you the usable video plan, copy pack, prompt, and next test.",
            urgency: "Do it while the product problem is fresh. The fastest sellers test one angle today, not next week.",
            valueStack: [
                ValueStackItem(title: "5-second video plan", value: "$15 value", reason: "A ready structure for the first TikTok-style sales test."),
                ValueStackItem(title: "Hook + Offer + CTA", value: "$20 value", reason: "The buying argument is already broken into usable parts."),
                ValueStackItem(title: "Platform captions", value: "$10 value", reason: "TikTok, Instagram, and Facebook copy are included."),
                ValueStackItem(title: "Money Plan", value: "$25 value", reason: "You get what to test, what signal to watch, and when to make Version B."),
                ValueStackItem(title: "JiMeng prompt", value: "$15 value", reason: "Ready to connect to real video rendering instead of prompt guessing.")
            ],
            objections: [
                ObjectionHandler(objection: "What if it does not sell?", answer: "This is a low-cost test, not a promise. The goal is to find the first signal before spending serious ad budget."),
                ObjectionHandler(objection: "Why not write it myself?", answer: "You can. But the app gives you category playbook, proof moment, scoring, and Version B logic in one flow."),
                ObjectionHandler(objection: "Why buy more than one?", answer: "Most winners come from the second or third version. The first test finds signal; Version B improves it.")
            ],
            offers: offers,
            recommendedOffer: offers.first { $0.title == recommended.title } ?? offers[0]
        )
    }

    static func checkoutCTA(for pack: RevenueAssetPack, balance: Double) -> String {
        if balance >= AppConfig.renderCost {
            return "Use $0.50 credit and unlock asset pack"
        }
        if pack.score.total >= 84 {
            return "Buy credits and test this strong angle"
        }
        return "Start with one low-cost sales test"
    }

    private static func recommendedOffer(for pack: RevenueAssetPack, moneyPlan: MoneyPlan, balance: Double) -> PurchaseOffer {
        if balance < AppConfig.renderCost {
            return PurchaseOffer(
                title: "1 Revenue Shot",
                price: "$0.99",
                badge: "Start here",
                creditValue: "1 render",
                primaryReason: moneyPlan.creditRecommendation.reason,
                cta: "Unlock this test",
                isRecommended: true
            )
        }
        if pack.score.repeatPotential >= 84 || pack.score.total >= 84 {
            return PurchaseOffer(
                title: "10 Revenue Shots",
                price: "$6.99",
                badge: "Best first pack",
                creditValue: "10 renders",
                primaryReason: "This product has enough signal potential to test Version B and adjacent angles.",
                cta: "Buy 10-shot pack",
                isRecommended: true
            )
        }
        return PurchaseOffer(
            title: "1 Revenue Shot",
            price: "$0.99",
            badge: "Start here",
            creditValue: "1 render",
            primaryReason: "The safest next step is one focused test before buying a larger pack.",
            cta: "Unlock this test",
            isRecommended: true
        )
    }
}
