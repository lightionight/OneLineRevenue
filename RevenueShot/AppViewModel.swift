import Foundation
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published var balance: Double = 8.50
    @Published var currentBrief = SampleRevenueData.demoBrief
    @Published var currentScan: RevenueScan?
    @Published var selectedAngle: SalesAngle?
    @Published var latestPack: RevenueAssetPack = SampleRevenueData.demoPack
    @Published var projects: [RevenueProject] = [
        RevenueProject(
            productName: SampleRevenueData.demoPack.productName,
            goal: .growSales,
            platform: "TikTok Shop",
            target: "Find a 5-second ad that can get first 20 orders",
            packs: [SampleRevenueData.demoPack]
        )
    ]
    @Published var receipts: [WalletReceipt] = [
        WalletReceipt(title: "Starter render credits", amount: 8.50, date: Date())
    ]
    @Published var isScanning = false
    @Published var isRendering = false
    @Published var errorMessage: String?
    @Published var latestVideoURL: URL?

    private let renderService: RenderService = LocalRenderService()

    var remainingRenders: Int {
        Int(balance / AppConfig.renderCost)
    }

    var canRender: Bool {
        balance >= AppConfig.renderCost && selectedAngle != nil && !isRendering
    }

    func runRevenueScan() async {
        isScanning = true
        defer { isScanning = false }
        try? await Task.sleep(nanoseconds: 450_000_000)
        let scan = RevenueEngine.scan(brief: currentBrief)
        currentScan = scan
        selectedAngle = scan.angles.first
    }

    func selectAngle(_ angle: SalesAngle) {
        selectedAngle = angle
    }

    func renderSelectedAngle() async {
        guard let angle = selectedAngle else {
            errorMessage = "Choose a sales angle before rendering."
            return
        }
        guard balance >= AppConfig.renderCost else {
            errorMessage = "You need at least $0.50 to render a revenue asset pack."
            return
        }

        isRendering = true
        defer { isRendering = false }
        let result: RenderJobResult
        do {
            result = try await renderService.render(RenderJobRequest(
                brief: currentBrief,
                angle: angle,
                imageData: nil,
                version: projects.flatMap(\.packs).count + 1
            ))
        } catch {
            errorMessage = "Render failed: \(error.localizedDescription)"
            return
        }

        let pack = result.pack
        latestVideoURL = result.videoURL
        balance = max(0, balance - pack.cost)
        latestPack = pack
        receipts.insert(WalletReceipt(title: "5-second revenue test render", amount: -pack.cost, date: Date()), at: 0)

        if let index = projects.firstIndex(where: { $0.productName.lowercased() == pack.productName.lowercased() }) {
            projects[index].packs.insert(pack, at: 0)
            projects[index].goal = currentBrief.goal
            projects[index].platform = currentBrief.platform
        } else {
            projects.insert(
                RevenueProject(
                    productName: pack.productName,
                    goal: currentBrief.goal,
                    platform: currentBrief.platform,
                    target: "Find a profitable first ad angle",
                    packs: [pack]
                ),
                at: 0
            )
        }
    }

    func exportLatestPack() {
        latestPack.status = .exported
        receipts.insert(WalletReceipt(title: "Asset pack exported", amount: 0, date: Date()), at: 0)
        if let projectIndex = projects.firstIndex(where: { $0.productName == latestPack.productName }),
           let packIndex = projects[projectIndex].packs.firstIndex(where: { $0.id == latestPack.id }) {
            projects[projectIndex].packs[packIndex].status = .exported
        }
    }

    func saveTestResult(_ result: TestResult) {
        latestPack.testResult = result
        latestPack.versionBPlan = GrowthStrategyEngine.versionBPlan(for: latestPack, result: result)
        if let projectIndex = projects.firstIndex(where: { $0.productName == latestPack.productName }),
           let packIndex = projects[projectIndex].packs.firstIndex(where: { $0.id == latestPack.id }) {
            projects[projectIndex].packs[packIndex].testResult = result
            projects[projectIndex].packs[packIndex].versionBPlan = latestPack.versionBPlan
        }
    }

    func topUp(_ amount: Double) {
        balance += amount
        receipts.insert(WalletReceipt(title: "Render credit top-up", amount: amount, date: Date()), at: 0)
    }
}
