import SwiftUI

struct MatchedResultsView: View {

    @Environment(AppCoordinator.self) private var coordinator
    let category: ProblemCategory
    let selectedTags: [String]

    private var matches: [MatchedProduct] {
        MatchingService.shared.match(
            category: category,
            selectedOptionTagSets: [selectedTags],
            products: coordinator.dataService.products
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(matches.isEmpty ? "No Standard Match Found" : "\(matches.count) Solution\(matches.count == 1 ? "" : "s") Found")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.iksWhite)
                    Text("For: \(category.name)")
                        .font(.subheadline)
                        .foregroundStyle(Color.iksGrey)
                }

                if matches.isEmpty {
                    // No match — route to Custom Solutions
                    VStack(spacing: 16) {
                        EmptyStateView(
                            icon: "wrench.and.screwdriver",
                            title: "No Standard Product Match",
                            message: "IK Subsea specialises in engineer-to-order solutions. Describe your challenge and our engineers will design a bespoke solution.",
                            actionTitle: "Explore Custom Solutions",
                            action: { coordinator.routeToCustomSolutions() }
                        )
                    }
                } else {
                    // Product cards
                    ForEach(matches) { match in
                        Button {
                            coordinator.finderPath.append(
                                SolutionFinderRoute.productDetail(productId: match.product.id)
                            )
                        } label: {
                            ProductCard(product: match.product, matchScore: match.score)
                        }
                        .buttonStyle(.plain)
                    }

                    // Soft CTA at bottom
                    VStack(alignment: .leading, spacing: 10) {
                        Divider().overlay(Color.iksNavyMid)
                        Text("Need something more specific?")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.iksWhite)
                        Text("IK Subsea engineers custom solutions for unique challenges. Contact our team to discuss your requirements.")
                            .font(.subheadline)
                            .foregroundStyle(Color.iksGrey)
                        Button {
                            coordinator.routeToCustomSolutions()
                        } label: {
                            Text("Enquire About Custom Solution")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.iksTeal)
                        }
                    }
                    .padding(16)
                    .iksCard()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.iksNavy.ignoresSafeArea())
    }
}
