import SwiftUI
import PhotosUI

struct GenerateView: View {
    @EnvironmentObject private var model: AppViewModel
    @StateObject private var imagePipeline = ProductImagePipeline()
    @State private var photo: PhotosPickerItem?
    @State private var showPack = false
    @State private var showCamera = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    hero
                    productInput
                    if let scan = model.currentScan {
                        scanPanel(scan)
                    } else {
                        exampleStrip
                    }
                    renderPanel
                }
                .padding(18)
            }
            .background(background)
            .navigationTitle("Revenue Shot")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showPack) {
                RenderDetailView(pack: model.latestPack)
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker { image in
                    imagePipeline.setCameraImage(image)
                    model.currentBrief.photoName = imagePipeline.imageName
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView {
                    Task {
                        await model.renderSelectedAngle()
                        showPack = true
                    }
                }
            }
            .alert("Product photo", isPresented: Binding(
                get: { imagePipeline.errorMessage != nil },
                set: { if !$0 { imagePipeline.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(imagePipeline.errorMessage ?? "")
            }
        }
    }

    private var background: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            Circle()
                .fill(Theme.gold.opacity(0.28))
                .frame(width: 280, height: 280)
                .blur(radius: 40)
                .offset(x: -120, y: -260)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Turn any product photo into a 5-second sales test.")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .lineSpacing(-4)
                .foregroundStyle(.white)
            Text("$0.50 per render. No prompt writing. Get the video idea, hook, offer, CTA, captions, and next test.")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.74))
            HStack(spacing: 10) {
                MetricPill(label: "BALANCE", value: String(format: "$%.2f", model.balance))
                MetricPill(label: "RENDERS", value: "\(model.remainingRenders)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(Theme.hero)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
    }

    private var productInput: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(
                eyebrow: "Step 1",
                title: "Scan the product",
                subtitle: "The app first diagnoses how this product might make money."
            )

            PhotosPicker(selection: $photo, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(LinearGradient(colors: [Theme.gold.opacity(0.42), Theme.flame.opacity(0.22)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    if let image = imagePipeline.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                            .overlay(alignment: .bottomLeading) {
                                Text("Product photo ready")
                                    .font(.headline.weight(.black))
                                    .foregroundStyle(.white)
                                    .padding(12)
                                    .background(.black.opacity(0.38))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .padding(12)
                            }
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: model.currentBrief.photoName.isEmpty ? "camera.viewfinder" : "shippingbox.fill")
                                .font(.system(size: 42, weight: .black))
                                .foregroundStyle(Theme.ink)
                            Text(model.currentBrief.photoName.isEmpty ? "Take or upload product photo" : "Product photo ready")
                                .font(.headline.weight(.black))
                                .foregroundStyle(Theme.ink)
                            Text(model.currentBrief.productName)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Theme.ink.opacity(0.68))
                        }
                    }
                }
                .frame(height: 170)
            }
            .onChange(of: photo) { item in
                Task {
                    await imagePipeline.load(item)
                    model.currentBrief.photoName = imagePipeline.imageName
                }
            }

            Button {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    showCamera = true
                } else {
                    imagePipeline.errorMessage = "Camera is not available on this device."
                }
            } label: {
                Label("Open camera", systemImage: "camera.fill")
                    .font(.subheadline.weight(.black))
            }

            TextField("Product name", text: $model.currentBrief.productName)
                .textFieldStyle(.roundedBorder)
            Picker("Goal", selection: $model.currentBrief.goal) {
                ForEach(RevenueGoal.allCases) { goal in
                    Text(goal.shortTitle).tag(goal)
                }
            }
            .pickerStyle(.segmented)
            Picker("Category", selection: $model.currentBrief.category) {
                ForEach(ProductCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.menu)
            TextField("Audience", text: $model.currentBrief.audience)
                .textFieldStyle(.roundedBorder)
            TextField("Platform", text: $model.currentBrief.platform)
                .textFieldStyle(.roundedBorder)
            TextEditor(text: $model.currentBrief.problem)
                .frame(minHeight: 105)
                .padding(10)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Button {
                Task { await model.runRevenueScan() }
            } label: {
                Label(model.isScanning ? "Scanning..." : "Scan revenue angles", systemImage: "sparkles")
                    .font(.headline.weight(.black))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.ink)
            .disabled(model.isScanning)
        }
        .revenueCard()
    }

    private func scanPanel(_ scan: RevenueScan) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(
                eyebrow: "Free preview",
                title: "Revenue scan",
                subtitle: "Show enough value before asking for the paid render."
            )
            HStack(spacing: 10) {
                scanMetric("Buyer", scan.buyer)
                scanMetric("Platform", scan.bestPlatform)
                scanMetric("Score", "\(scan.confidence)%")
            }
            CopyLine(title: "Core pain", body: scan.corePain)
            CopyLine(title: "Buying trigger", body: scan.buyingTrigger)
            CopyLine(title: "Trust barrier", body: scan.trustBarrier)
            playbookPreview

            Text("Choose one sales angle")
                .font(.headline.weight(.black))
                .padding(.top, 4)

            ForEach(scan.angles) { angle in
                AngleCard(angle: angle, isSelected: model.selectedAngle?.id == angle.id) {
                    model.selectAngle(angle)
                }
            }
        }
        .revenueCard()
    }

    private var playbookPreview: some View {
        let category = GrowthStrategyEngine.detectCategory(from: model.currentBrief)
        let playbook = GrowthStrategyEngine.playbook(for: category)
        return VStack(alignment: .leading, spacing: 8) {
            Text("\(category.rawValue) playbook")
                .font(.caption.weight(.black))
                .foregroundStyle(Theme.flame)
            Text(playbook.winningPattern)
                .font(.subheadline.weight(.black))
            Text("Proof: \(playbook.proofMoment)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Theme.gold.opacity(0.22))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func scanMetric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.caption2.weight(.black))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.black))
                .foregroundStyle(Theme.ink)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Theme.paper.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var exampleStrip: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(
                eyebrow: "Examples",
                title: "What a sales test looks like",
                subtitle: "Users need to see their own product in these patterns."
            )
            ExampleCard(category: "Beauty", angle: "Save morning time", result: "Before/after 5-second routine")
            ExampleCard(category: "Kitchen", angle: "One wipe proof", result: "Satisfying cleaning transformation")
            ExampleCard(category: "Pet", angle: "Rainy day problem", result: "Keep floors clean after walks")
        }
        .revenueCard()
    }

    private var renderPanel: some View {
        let plan = GrowthStrategyEngine.moneyPlan(for: model.latestPack, balance: model.balance)
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(
                eyebrow: "Step 2",
                title: "Unlock the full asset pack",
                subtitle: "The free scan creates belief. The paid render creates the usable revenue asset."
            )
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("$0.50")
                        .font(.largeTitle.weight(.black))
                    Text("one 5-second revenue test")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.system(size: 42, weight: .black))
                    .foregroundStyle(Theme.flame)
            }
            CopyLine(title: "Why pay now", body: "This render turns the selected angle into a complete asset pack and a first-test plan. The next screen will show what to test, what signal to watch, and how to create Version B.")
            CopyLine(title: "Recommended next purchase", body: "\(plan.creditRecommendation.title) — \(plan.creditRecommendation.reason)")
            Button {
                showPaywall = true
            } label: {
                Text(model.isRendering ? "Rendering..." : ConversionEngine.checkoutCTA(for: model.latestPack, balance: model.balance))
                    .font(.headline.weight(.black))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.flame)
            .disabled(!model.canRender)
        }
        .revenueCard()
    }
}

struct AngleCard: View {
    let angle: SalesAngle
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(angle.type.rawValue)
                        .font(.caption.weight(.black))
                        .foregroundStyle(isSelected ? .white : Theme.flame)
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? .white : .secondary)
                }
                Text(angle.title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(isSelected ? .white : Theme.ink)
                Text(angle.hook)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isSelected ? .white.opacity(0.78) : .secondary)
                Text(angle.expectedSignal)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isSelected ? .white.opacity(0.68) : .secondary)
            }
            .padding(16)
            .background(isSelected ? Theme.ink : .white.opacity(0.76))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct ExampleCard: View {
    let category: String
    let angle: String
    let result: String

    var body: some View {
        HStack(spacing: 14) {
            Text(category.prefix(1))
                .font(.title2.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Theme.flame)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.caption.weight(.black))
                    .foregroundStyle(Theme.flame)
                Text(angle)
                    .font(.headline.weight(.black))
                Text(result)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(.white.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
