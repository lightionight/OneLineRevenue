import Foundation

struct RenderJobRequest {
    let brief: ProductBrief
    let angle: SalesAngle
    let imageData: Data?
    let version: Int
}

struct RenderJobResult {
    let pack: RevenueAssetPack
    let videoURL: URL?
}

protocol RenderService {
    func render(_ request: RenderJobRequest) async throws -> RenderJobResult
}

struct LocalRenderService: RenderService {
    func render(_ request: RenderJobRequest) async throws -> RenderJobResult {
        try await Task.sleep(nanoseconds: 700_000_000)
        let pack = RevenueEngine.makeAssetPack(
            brief: request.brief,
            angle: request.angle,
            version: request.version
        )
        return RenderJobResult(pack: pack, videoURL: nil)
    }
}

struct BackendRenderService: RenderService {
    let baseURL: URL

    func render(_ request: RenderJobRequest) async throws -> RenderJobResult {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent("/api/renders"))
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")

        let payload = BackendRenderPayload(
            productName: request.brief.productName,
            goal: request.brief.goal.rawValue,
            problem: request.brief.problem,
            audience: request.brief.audience,
            platform: request.brief.platform,
            imageName: request.brief.photoName,
            imageData: request.imageData?.base64EncodedString() ?? "",
            angleTitle: request.angle.title
        )
        urlRequest.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw RenderServiceError.backendFailed
        }

        let decoded = try JSONDecoder().decode(BackendRenderResponse.self, from: data)
        return RenderJobResult(
            pack: decoded.toAssetPack(fallbackAngle: request.angle),
            videoURL: decoded.videoURL.flatMap(URL.init(string:))
        )
    }
}

enum RenderServiceError: Error {
    case backendFailed
}

private struct BackendRenderPayload: Encodable {
    let productName: String
    let goal: String
    let problem: String
    let audience: String
    let platform: String
    let imageName: String
    let imageData: String
    let angleTitle: String
}

private struct BackendRenderResponse: Decodable {
    let productName: String
    let status: String
    let videoURL: String?
    let assetPack: BackendAssetPack

    func toAssetPack(fallbackAngle: SalesAngle) -> RevenueAssetPack {
        RevenueAssetPack(
            productName: productName,
            angle: fallbackAngle,
            cost: AppConfig.renderCost,
            status: status == "exported" ? .exported : .ready,
            createdAt: Date(),
            headline: assetPack.headline,
            offer: assetPack.offer,
            cta: assetPack.cta,
            videoConcept: assetPack.videoConcept,
            timeline: assetPack.timeline.map { TimelineBeat(time: $0.time, line: $0.line, visual: $0.visual) },
            copies: assetPack.copies.map { AssetCopy(title: $0.title, body: $0.body) },
            prompt: PromptPack(positive: assetPack.prompt.positive, negative: assetPack.prompt.negative),
            score: GrowthStrategyEngine.score(
                brief: ProductBrief(
                    productName: productName,
                    goal: .growSales,
                    audience: "US shoppers",
                    platform: "TikTok Shop",
                    problem: assetPack.offer,
                    photoName: "",
                    category: .general
                ),
                angle: fallbackAngle,
                playbook: GrowthStrategyEngine.playbook(for: .general)
            ),
            versionBPlan: VersionBPlan(
                title: "Version B: proof-first test",
                keep: "Keep the strongest sales angle from this render.",
                change: "Move the proof moment earlier and make the offer clearer.",
                whyItCanMakeMoney: "Earlier proof can improve attention and clearer offer can improve conversion.",
                recommendedBudget: "$10-$20"
            ),
            playbook: GrowthStrategyEngine.playbook(for: .general),
            testResult: nil
        )
    }
}

private struct BackendAssetPack: Decodable {
    let headline: String
    let offer: String
    let cta: String
    let videoConcept: String
    let timeline: [BackendTimeline]
    let copies: [BackendCopy]
    let prompt: BackendPrompt
}

private struct BackendTimeline: Decodable {
    let time: String
    let line: String
    let visual: String
}

private struct BackendCopy: Decodable {
    let title: String
    let body: String
}

private struct BackendPrompt: Decodable {
    let positive: String
    let negative: String
}
