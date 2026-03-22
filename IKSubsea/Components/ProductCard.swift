import SwiftUI

struct ProductCard: View {
    let product: Product
    var matchScore: Double? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Domain badge + emergency indicator
            HStack {
                DomainBadge(domain: product.domain)
                if product.isEmergencyCapable {
                    Label("Emergency", systemImage: "bolt.fill")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.iksOrange)
                }
                Spacer()
                if let score = matchScore {
                    MatchScoreBadge(score: score)
                }
            }

            // Name
            Text(product.name)
                .font(.headline)
                .foregroundStyle(Color.iksWhite)
                .lineLimit(2)

            // Short description
            Text(product.shortDescription)
                .font(.subheadline)
                .foregroundStyle(Color.iksGrey)
                .lineLimit(3)

            // Install method chips
            HStack(spacing: 6) {
                ForEach(product.installationMethods, id: \.self) { method in
                    Text(method.displayLabel)
                        .font(.caption)
                        .foregroundStyle(Color.iksTeal)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .overlay(Capsule().strokeBorder(Color.iksTeal.opacity(0.5), lineWidth: 1))
                }
                Spacer()
            }
        }
        .padding(14)
        .iksCard()
    }
}
