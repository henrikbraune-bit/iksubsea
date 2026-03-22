import Foundation

struct MatchedProduct: Identifiable, Hashable {
    var id: UUID { product.id }
    let product: Product
    let score: Double       // 0.0 – 1.0
    let matchingTags: [String]
}

final class MatchingService {

    static let shared = MatchingService()
    private init() {}

    /// Returns products scored by tag intersection, sorted best-first.
    /// Threshold: 0.30 (at least 30% of query tags must match).
    func match(
        category: ProblemCategory,
        selectedOptionTagSets: [[String]],
        products: [Product]
    ) -> [MatchedProduct] {

        // Build the unified query tag set
        var queryTags = Set(category.relatedTags)
        for tagSet in selectedOptionTagSets {
            queryTags.formUnion(tagSet)
        }

        let isEmergencyQuery = queryTags.contains("emergency")

        let scored: [MatchedProduct] = products.compactMap { product in
            let productTagSet = Set(product.problemTags)
            let intersection = queryTags.intersection(productTagSet)

            guard !intersection.isEmpty else { return nil }

            let score = Double(intersection.count) / Double(queryTags.count)
            guard score >= 0.30 else { return nil }

            return MatchedProduct(
                product: product,
                score: score,
                matchingTags: Array(intersection).sorted()
            )
        }

        return scored.sorted {
            // Emergency-capable products float to top when emergency is in query
            if isEmergencyQuery && $0.product.isEmergencyCapable != $1.product.isEmergencyCapable {
                return $0.product.isEmergencyCapable
            }
            return $0.score > $1.score
        }
    }
}
