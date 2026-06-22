import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject private var model: AppViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionTitle(
                        eyebrow: "Tests",
                        title: "Revenue test history",
                        subtitle: "Every render should become a learning asset, not a forgotten file."
                    )
                    ForEach(model.projects) { project in
                        NavigationLink {
                            ProjectDetailView(project: project)
                        } label: {
                            ProjectCard(project: project)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(18)
            }
            .background(Theme.paper.ignoresSafeArea())
            .navigationTitle("Tests")
        }
    }
}

struct ProjectCard: View {
    let project: RevenueProject

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(project.productName)
                        .font(.title3.weight(.black))
                    Text(project.goal.rawValue)
                        .font(.caption.weight(.black))
                        .foregroundStyle(Theme.flame)
                }
                Spacer()
                Text("\(project.packs.count) packs")
                    .font(.caption.weight(.black))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Theme.gold.opacity(0.7))
                    .clipShape(Capsule())
            }
            CopyLine(title: "Target", body: project.target)
            HStack {
                Label(project.platform, systemImage: "megaphone.fill")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(.caption.weight(.black))
            .foregroundStyle(.secondary)
        }
        .revenueCard()
    }
}

struct ProjectDetailView: View {
    let project: RevenueProject

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(project.productName)
                        .font(.largeTitle.weight(.black))
                        .foregroundStyle(.white)
                    Text(project.target)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.76))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .background(Theme.money)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))

                ForEach(project.packs) { pack in
                    NavigationLink {
                        RenderDetailView(pack: pack)
                            .padding(18)
                            .background(Theme.paper.ignoresSafeArea())
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "play.rectangle.fill")
                                .font(.title2)
                                .foregroundStyle(Theme.flame)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pack.angle.title)
                                    .font(.headline.weight(.black))
                                    .foregroundStyle(Theme.ink)
                                Text(pack.headline)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Text(pack.status.rawValue)
                                .font(.caption.weight(.black))
                                .foregroundStyle(Theme.flame)
                        }
                        .padding(14)
                        .background(.white.opacity(0.80))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(18)
        }
        .background(Theme.paper.ignoresSafeArea())
        .navigationTitle("Project")
        .navigationBarTitleDisplayMode(.inline)
    }
}
