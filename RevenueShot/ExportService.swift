import Foundation
import SwiftUI
import UIKit

enum ExportService {
    static func makeShareText(for pack: RevenueAssetPack) -> String {
        let copies = pack.copies
            .map { "\($0.title):\n\($0.body)" }
            .joined(separator: "\n\n")

        return """
        Revenue Shot Asset Pack

        Product: \(pack.productName)
        Angle: \(pack.angle.title)
        Headline: \(pack.headline)

        5-Second Timeline:
        \(pack.timeline.map { "\($0.time): \($0.line) — \($0.visual)" }.joined(separator: "\n"))

        \(copies)

        Prompt:
        \(pack.prompt.positive)

        Negative Prompt:
        \(pack.prompt.negative)
        """
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
