import Foundation

enum RevenueGoal: String, CaseIterable, Identifiable {
    case growSales = "Grow existing sales"
    case testSideIncome = "Test a new income stream"
    case validateMarket = "Validate a product market"

    var id: String { rawValue }

    var shortTitle: String {
        switch self {
        case .growSales: return "Grow sales"
        case .testSideIncome: return "Side income"
        case .validateMarket: return "Validate"
        }
    }
}

enum SalesAngleType: String, CaseIterable, Identifiable {
    case proof = "Proof"
    case pain = "Pain"
    case gift = "Gift"
    case time = "Time"
    case identity = "Identity"

    var id: String { rawValue }

    var explanation: String {
        switch self {
        case .proof: return "Show visible proof before asking for trust."
        case .pain: return "Name the annoying moment your product fixes."
        case .gift: return "Make the product feel like an easy gift decision."
        case .time: return "Sell saved time, not just product features."
        case .identity: return "Connect the product to who the buyer wants to be."
        }
    }
}

enum ProductCategory: String, CaseIterable, Identifiable {
    case beauty = "Beauty"
    case kitchen = "Kitchen"
    case pet = "Pet"
    case home = "Home"
    case fitness = "Fitness"
    case general = "General"

    var id: String { rawValue }
}

enum RenderStatus: String, Codable {
    case draft = "Draft"
    case rendering = "Rendering"
    case ready = "Ready"
    case exported = "Exported"
}

struct ProductBrief: Identifiable, Hashable {
    let id = UUID()
    var productName: String
    var goal: RevenueGoal
    var audience: String
    var platform: String
    var problem: String
    var photoName: String
    var category: ProductCategory
}

struct RevenueScan: Identifiable, Hashable {
    let id = UUID()
    let productName: String
    let buyer: String
    let corePain: String
    let buyingTrigger: String
    let trustBarrier: String
    let bestPlatform: String
    let confidence: Int
    let angles: [SalesAngle]
}

struct SalesAngle: Identifiable, Hashable {
    let id = UUID()
    let type: SalesAngleType
    let title: String
    let hook: String
    let reason: String
    let expectedSignal: String
    let repurchaseTrigger: String
}

struct RevenueScore: Hashable {
    let hookStrength: Int
    let proofStrength: Int
    let offerClarity: Int
    let platformFit: Int
    let repeatPotential: Int

    var total: Int {
        (hookStrength + proofStrength + offerClarity + platformFit + repeatPotential) / 5
    }
}

struct VersionBPlan: Hashable {
    let title: String
    let keep: String
    let change: String
    let whyItCanMakeMoney: String
    let recommendedBudget: String
}

struct RevenueForecast: Hashable {
    let testBudget: String
    let expectedClicks: String
    let expectedOrders: String
    let breakEvenOrderValue: String
    let confidenceNote: String
}

struct CreditRecommendation: Hashable {
    let title: String
    let price: String
    let reason: String
    let bestFor: String
}

struct ExperimentStep: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let action: String
    let successSignal: String
    let nextIfWins: String
}

struct MoneyPlan: Hashable {
    let forecast: RevenueForecast
    let creditRecommendation: CreditRecommendation
    let steps: [ExperimentStep]
    let retentionHook: String
}

struct ValueStackItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: String
    let reason: String
}

struct ObjectionHandler: Identifiable, Hashable {
    let id = UUID()
    let objection: String
    let answer: String
}

struct PurchaseOffer: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let price: String
    let badge: String
    let creditValue: String
    let primaryReason: String
    let cta: String
    let isRecommended: Bool
}

struct PaywallPlan: Hashable {
    let headline: String
    let subheadline: String
    let urgency: String
    let valueStack: [ValueStackItem]
    let objections: [ObjectionHandler]
    let offers: [PurchaseOffer]
    let recommendedOffer: PurchaseOffer
}

struct CategoryPlaybook: Identifiable, Hashable {
    let id = UUID()
    let category: ProductCategory
    let winningPattern: String
    let proofMoment: String
    let trustBuilder: String
    let bestFirstAngles: [SalesAngleType]
}

struct TimelineBeat: Identifiable, Codable, Hashable {
    let id = UUID()
    let time: String
    let line: String
    let visual: String
}

struct AssetCopy: Identifiable, Codable, Hashable {
    let id = UUID()
    let title: String
    let body: String
}

struct PromptPack: Codable, Hashable {
    let positive: String
    let negative: String
}

struct RevenueAssetPack: Identifiable, Hashable {
    let id = UUID()
    let productName: String
    let angle: SalesAngle
    let cost: Double
    var status: RenderStatus
    let createdAt: Date
    let headline: String
    let offer: String
    let cta: String
    let videoConcept: String
    let timeline: [TimelineBeat]
    let copies: [AssetCopy]
    let prompt: PromptPack
    let score: RevenueScore
    var versionBPlan: VersionBPlan
    let playbook: CategoryPlaybook
    var testResult: TestResult?

    var costLabel: String {
        String(format: "$%.2f", cost)
    }
}

struct TestResult: Hashable {
    var spend: String
    var clicks: String
    var addToCarts: String
    var orders: String
    var learning: String
    var nextMove: String
}

struct RevenueProject: Identifiable, Hashable {
    let id = UUID()
    var productName: String
    var goal: RevenueGoal
    var platform: String
    var target: String
    var packs: [RevenueAssetPack]
}

struct WalletReceipt: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let amount: Double
    let date: Date
}

enum SampleRevenueData {
    static let demoBrief = ProductBrief(
        productName: "Heatless Curling Band",
        goal: .growSales,
        audience: "US women, 22-35, busy mornings",
        platform: "TikTok Shop",
        problem: "People like the product but do not believe it saves real morning time.",
        photoName: "demo-product.jpg",
        category: .beauty
    )

    static let demoAngle = SalesAngle(
        type: .time,
        title: "Save 30 minutes tomorrow morning",
        hook: "Still waking up early just to curl your hair?",
        reason: "The buyer is not buying a hair accessory. She is buying back sleep.",
        expectedSignal: "Watch for saves, comments about morning routines, and clicks from women 22-35.",
        repurchaseTrigger: "If clicks are strong, render Version B with the final curl reveal in the first second."
    )

    static let demoPack = RevenueAssetPack(
        productName: "Heatless Curling Band",
        angle: demoAngle,
        cost: AppConfig.renderCost,
        status: .ready,
        createdAt: Date(),
        headline: "Wake up curled. No heat. No rushed mornings.",
        offer: "Wrap it before bed and wake up with soft curls without heat damage.",
        cta: "Try it tonight before tomorrow morning.",
        videoConcept: "A 5-second before/after morning routine ad showing the pain of waking early, the simple wrap, and the next-morning result.",
        timeline: [
            TimelineBeat(time: "0-1s", line: "Still waking up early to curl?", visual: "Alarm at 6:30 AM, tired face, messy hair."),
            TimelineBeat(time: "1-3s", line: "Wrap before bed. No heat.", visual: "Hands wrap hair around the product in a cozy bedroom."),
            TimelineBeat(time: "3-5s", line: "Wake up ready.", visual: "Bright bathroom reveal with soft curls and price cue.")
        ],
        copies: [
            AssetCopy(title: "Hook (opening line)", body: "Still waking up early just to curl your hair?"),
            AssetCopy(title: "Offer (why to buy)", body: "Wake up with soft curls without heat damage or morning rush."),
            AssetCopy(title: "CTA (call to action)", body: "Try it tonight before tomorrow morning."),
            AssetCopy(title: "TikTok caption", body: "I tested the overnight curl band so you can sleep 30 minutes longer."),
            AssetCopy(title: "Landing hero", body: "Wake up curled. No heat. No rushed mornings."),
            AssetCopy(title: "DM follow-up", body: "If morning styling steals your sleep, this is the small fix I would test first.")
        ],
        prompt: PromptPack(
            positive: "Create a 5-second vertical TikTok Shop UGC ad for a heatless curling band. Show alarm clock pain, simple bedtime wrap, next-morning curls, readable captions, real product close-up, high conversion energy.",
            negative: "No distorted hands, no fake app UI, no watermark, no celebrity likeness, no unrealistic hair transformation."
        ),
        score: RevenueScore(
            hookStrength: 84,
            proofStrength: 78,
            offerClarity: 86,
            platformFit: 88,
            repeatPotential: 82
        ),
        versionBPlan: VersionBPlan(
            title: "Version B: reveal first",
            keep: "Keep the morning-time hook because the pain is instantly understood.",
            change: "Move the final curl reveal into the first second, then explain the overnight wrap.",
            whyItCanMakeMoney: "A faster proof moment can raise thumb-stop rate and make the same audience trust the product sooner.",
            recommendedBudget: "$10-$20"
        ),
        playbook: CategoryPlaybook(
            category: .beauty,
            winningPattern: "Before/after transformation with a believable routine.",
            proofMoment: "Show the final look early, then show how easy the routine is.",
            trustBuilder: "Use natural lighting, real hair texture, and no exaggerated claims.",
            bestFirstAngles: [.proof, .time, .identity]
        ),
        testResult: TestResult(
            spend: "$10",
            clicks: "41",
            addToCarts: "7",
            orders: "2",
            learning: "The time-saving angle got clicks because the pain was instantly understood.",
            nextMove: "Create Version B with the final curl reveal in the first second."
        )
    )
}
