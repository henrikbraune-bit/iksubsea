import SwiftUI

struct CaseStudyDetailView: View {

    @Environment(AppCoordinator.self) private var coordinator
    let caseStudy: CaseStudy

    @State private var selectedProduct: Product? = nil

    var relatedProducts: [Product] {
        caseStudy.relatedProductIds.compactMap { coordinator.dataService.product(id: $0) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Meta
                VStack(alignment: .leading, spacing: 8) {
                    DomainBadge(domain: caseStudy.domain)

                    Text(caseStudy.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.iksWhite)

                    HStack(spacing: 16) {
                        Label(caseStudy.location, systemImage: "mappin.and.ellipse")
                        if let depth = caseStudy.waterDepth {
                            Label(depth, systemImage: "arrow.down.to.line")
                        }
                        if let year = caseStudy.year {
                            Label(String(year), systemImage: "calendar")
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.iksGrey)

                    if let client = caseStudy.client {
                        Label("Client: \(client)", systemImage: "building.2")
                            .font(.subheadline)
                            .foregroundStyle(Color.iksTeal)
                    }
                }

                Divider().overlay(Color.iksNavyMid)

                // Problem
                section(icon: "exclamationmark.triangle", title: "The Challenge", body: caseStudy.problemSummary)

                // Solution
                section(icon: "wrench.and.screwdriver", title: "The Solution", body: caseStudy.solution)

                // Outcome
                section(icon: "checkmark.seal", title: "Outcome", body: caseStudy.outcome)

                // Products used
                if !relatedProducts.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        IKSSectionHeader(title: "Products Used")
                        ForEach(relatedProducts) { product in
                            Button {
                                selectedProduct = product
                            } label: {
                                HStack {
                                    DomainBadge(domain: product.domain)
                                    product.name.trademarked(font: .subheadline.weight(.medium), symbolSize: 8, symbolOffset: 3)
                                        .foregroundStyle(Color.iksWhite)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color.iksGrey)
                                }
                                .padding(12)
                                .iksCard()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle("Case Study")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.iksNavy.ignoresSafeArea())
        .sheet(item: $selectedProduct) { product in
            NavigationStack {
                ProductDetailView(product: product)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { selectedProduct = nil }
                                .foregroundStyle(Color.iksTeal)
                        }
                    }
            }
            .environment(coordinator)
        }
    }

    @ViewBuilder
    private func section(icon: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(Color.iksTeal)
            Text(body)
                .font(.body)
                .foregroundStyle(Color.iksWhite)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
