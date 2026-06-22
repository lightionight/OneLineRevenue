import Foundation

enum AppConfig {
    static let appName = "Revenue Shot"
    static let renderCost: Double = 0.50
    static let backendBaseURL = URL(string: "https://api.your-domain.com")!

    enum ProductID {
        static let oneRender = "com.revenueshot.credits.1"
        static let tenRenders = "com.revenueshot.credits.10"
        static let fiftyRenders = "com.revenueshot.credits.50"
        static let proMonthly = "com.revenueshot.pro.monthly"

        static let all = [oneRender, tenRenders, fiftyRenders, proMonthly]
    }

    static func credits(for productID: String) -> Double {
        switch productID {
        case ProductID.oneRender: return 0.50
        case ProductID.tenRenders: return 5.00
        case ProductID.fiftyRenders: return 25.00
        case ProductID.proMonthly: return 20.00
        default: return 0
        }
    }
}
