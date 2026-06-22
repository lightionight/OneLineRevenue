import SwiftUI

enum Theme {
    static let ink = Color(red: 0.06, green: 0.07, blue: 0.08)
    static let paper = Color(red: 0.98, green: 0.94, blue: 0.84)
    static let flame = Color(red: 1.0, green: 0.29, blue: 0.10)
    static let gold = Color(red: 1.0, green: 0.76, blue: 0.18)
    static let mint = Color(red: 0.12, green: 0.82, blue: 0.45)
    static let denim = Color(red: 0.08, green: 0.13, blue: 0.24)

    static let hero = LinearGradient(
        colors: [ink, denim, flame],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let money = LinearGradient(
        colors: [mint, Color(red: 0.01, green: 0.42, blue: 0.28)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension View {
    func revenueCard(radius: CGFloat = 26) -> some View {
        padding(18)
            .background(.white.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)
    }
}

struct SectionTitle: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .font(.caption.weight(.black))
                .tracking(1.2)
                .foregroundStyle(Theme.flame)
            Text(title)
                .font(.title2.weight(.black))
                .foregroundStyle(Theme.ink)
            Text(subtitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MetricPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2.weight(.black))
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .font(.headline.weight(.black))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
