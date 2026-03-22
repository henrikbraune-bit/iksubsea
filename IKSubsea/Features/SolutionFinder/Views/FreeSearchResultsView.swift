import SwiftUI

// MARK: - Free Text Matching Engine

/// Converts natural language query into product matches without requiring
/// the user to go through category selection.
struct FreeSearchEngine {

    // Keyword -> tag mappings covering common subsea vocabulary
    static let keywordMap: [(keywords: [String], tags: [String])] = [
        // Leaks & sealing
        (["leak", "leaking", "leakage", "seal", "sealing", "loss of containment"],
         ["pipeline-leak", "flange-leak", "weld-defect"]),
        (["flange", "connector", "coupling", "hub"],
         ["flange-leak", "connector-failure"]),
        (["gasket", "packer"],
         ["gasket-failure", "flange-leak"]),
        (["pinhole", "perforation", "penetration"],
         ["pinhole", "pipe-penetration-leak"]),
        (["flexible", "flexflow", "flex flow", "outer sheath"],
         ["flexible-damage", "tight-access"]),
        (["riser"],
         ["pipeline-leak", "structural-damage"]),

        // Structural damage
        (["crack", "cracked", "cracking", "fracture"],
         ["crack", "structural-damage", "pipeline-structural-failure"]),
        (["structural", "structure", "buckle", "collapse", "deformation"],
         ["structural-damage", "platform-repair"]),
        (["jacket", "conductor", "platform", "plem", "manifold"],
         ["platform-repair", "jacket-damage", "structural-damage"]),
        (["weld", "welding", "weld defect"],
         ["weld-defect", "crack"]),
        (["xmas tree", "christmas tree", "xt", "tree"],
         ["structural-damage", "ultra-deepwater", "tight-access"]),

        // Isolation & plugging
        (["isolat", "plug", "plugging", "block", "shut in", "shut-in"],
         ["pipeline-isolation", "decommissioning"]),
        (["decommission", "decom", "abandon", "abandonment"],
         ["decommissioning", "pipeline-isolation"]),
        (["valve", "sea chest", "vessel"],
         ["pipeline-isolation"]),

        // Lifting & handling
        (["lift", "lifting", "hoist", "raise"],
         ["subsea-lifting", "flexible-lifting"]),
        (["recovery", "recover", "retrieve"],
         ["cable-recovery", "flexible-lifting", "decommissioning"]),
        (["umbilical"],
         ["umbilical-handling", "flexible-lifting"]),
        (["cable"],
         ["cable-recovery", "flexible-lifting"]),
        (["hang", "hang-off", "holdback", "hold back"],
         ["subsea-lifting"]),
        (["install", "installation", "deploy"],
         ["installation", "pipeline-installation"]),

        // Corrosion & cathodic protection
        (["anode", "anodes", "cathodic", "corrosion", "corroded"],
         ["cathodic-protection", "anode-retrofit"]),
        (["sacrificial"],
         ["cathodic-protection", "corrosion"]),

        // Depth
        (["deepwater", "deep water", "ultra deep", "ultra-deep"],
         ["ultra-deepwater"]),
        (["shallow", "splash zone", "surface"],
         ["shallow-water"]),

        // Urgency
        (["emergency", "urgent", "critical", "immediate", "asap"],
         ["emergency"]),

        // Service conditions
        (["sour", "h2s", "hydrogen sulphide", "hydrogen sulfide"],
         ["sour-service"]),
        (["high pressure", "high-pressure", "hpht"],
         ["pipeline-leak"]),

        // Tooling
        (["rov", "remotely operated"],
         ["pipeline-leak", "pipeline-isolation", "ultra-deepwater"]),
        (["coating", "mill", "milling", "surface prep"],
         ["surface-prep"]),
        (["grout", "grouting"],
         ["structural-grouting", "platform-repair"]),
        (["torque", "bolt"],
         ["subsea-assembly"]),

        // Pipeline types
        (["pipeline", "pipe", "flowline", "flow line"],
         ["pipeline-leak", "pipeline-structural-failure"]),
    ]

    static func extractTags(from query: String) -> [String] {
        let lower = query.lowercased()
        var tags = Set<String>()

        for entry in keywordMap {
            for keyword in entry.keywords {
                if lower.contains(keyword) {
                    entry.tags.forEach { tags.insert($0) }
                    break
                }
            }
        }
        return Array(tags)
    }

    static func score(product: Product, tags: [String], query: String) -> Double {
        let querySet = Set(tags)
        let productSet = Set(product.problemTags)
        let tagIntersection = querySet.intersection(productSet)

        // Base score: tag overlap
        var score = querySet.isEmpty ? 0.0 : Double(tagIntersection.count) / Double(querySet.count)

        // Bonus: product name or description contains query words
        let words = query.lowercased().split(separator: " ").map(String.init)
        let nameBonus = words.filter { product.name.lowercased().contains($0) }.count
        let descBonus = words.filter { product.shortDescription.lowercased().contains($0) }.count
        score += Double(nameBonus) * 0.15
        score += Double(descBonus) * 0.05

        return min(score, 1.0)
    }
}

// MARK: - FreeSearchResultsView

struct FreeSearchResultsView: View {

    @Environment(AppCoordinator.self) private var coordinator
    let query: String

    private var extractedTags: [String] {
        FreeSearchEngine.extractTags(from: query)
    }

    private var matches: [MatchedProduct] {
        let tags = extractedTags
        let isEmergency = tags.contains("emergency")

        let scored: [MatchedProduct] = coordinator.dataService.products.compactMap { product in
            let score = FreeSearchEngine.score(product: product, tags: tags, query: query)
            guard score > 0.10 else { return nil }
            let matching = Set(tags).intersection(Set(product.problemTags))
            return MatchedProduct(product: product, score: score, matchingTags: Array(matching).sorted())
        }

        return scored.sorted {
            if isEmergency && $0.product.isEmergencyCapable != $1.product.isEmergencyCapable {
                return $0.product.isEmergencyCapable
            }
            return $0.score > $1.score
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(Color.iksTeal)
                        Text(matches.isEmpty ? "No Match Found" : "\(matches.count) Solution\(matches.count == 1 ? "" : "s") Found")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.iksWhite)
                    }
                    Text("For: \"\(query)\"")
                        .font(.subheadline)
                        .foregroundStyle(Color.iksGrey)
                        .lineLimit(2)
                }

                // Detected keywords pill row (shows what was understood)
                if !extractedTags.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DETECTED CONCEPTS")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.iksGrey)
                        FlowLayout(spacing: 6) {
                            ForEach(extractedTags.prefix(8), id: \.self) { tag in
                                Text(tag.replacingOccurrences(of: "-", with: " "))
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Color.iksTeal)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.iksTeal.opacity(0.12))
                                    .clipShape(Capsule())
                                    .overlay(Capsule().strokeBorder(Color.iksTeal.opacity(0.3), lineWidth: 1))
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.iksNavyMid.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                if matches.isEmpty {
                    EmptyStateView(
                        icon: "sparkles",
                        title: "No Standard Product Match",
                        message: "IK Subsea specialises in engineer-to-order solutions. Describe your challenge and our engineers will design a bespoke solution.",
                        actionTitle: "Explore Custom Solutions",
                        action: { coordinator.routeToCustomSolutions() }
                    )
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
        .navigationTitle("Smart Match")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.iksNavy.ignoresSafeArea())
    }
}
