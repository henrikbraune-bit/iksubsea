import SwiftUI

struct IKSCardModifier: ViewModifier {
    var selected: Bool = false

    func body(content: Content) -> some View {
        content
            .background(Color.iksNavyMid)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        selected ? Color.iksTeal : Color.iksTeal.opacity(0.25),
                        lineWidth: selected ? 1.5 : 1
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

extension View {
    func iksCard(selected: Bool = false) -> some View {
        modifier(IKSCardModifier(selected: selected))
    }
}

// MARK: - Domain Badge

struct DomainBadge: View {
    let domain: ProductDomain

    var color: Color {
        switch domain {
        case .repair:     return Color.iksOrange      // #E07B30 warm amber - repair/emergency
        case .isolation:  return Color.iksTeal         // #3BD9CC IK medium sea - isolation
        case .lifting:    return Color.iksSeaGreen     // #66F2C2 IK green sea - lifting/handling
        case .tooling:    return Color.iksGrey         // #507E8A muted - support tooling domain
        case .structural: return Color.iksSeaGreen     // #66F2C2 IK green sea - structural integrity
        }
    }

    var textColor: Color {
        switch domain {
        case .repair:    return .white
        case .isolation: return Color.iksNavy
        case .lifting:   return Color.iksNavy
        case .tooling:   return Color.iksWhite
        case .structural: return Color.iksNavy
        }
    }

    var body: some View {
        Text(domain.rawValue)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.90))
            .clipShape(Capsule())
    }
}

// MARK: - Section Header

struct IKSSectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.iksWhite)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.iksGrey)
            }
        }
    }
}
