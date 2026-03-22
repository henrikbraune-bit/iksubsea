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
        Text(domain.displayName)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.90))
            .clipShape(Capsule())
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            for subview in subviews {
                let viewSize = subview.sizeThatFits(.unspecified)
                if x + viewSize.width > maxWidth, x > 0 {
                    y += lineHeight + spacing
                    x = 0
                    lineHeight = 0
                }
                frames.append(CGRect(origin: CGPoint(x: x, y: y), size: viewSize))
                x += viewSize.width + spacing
                lineHeight = max(lineHeight, viewSize.height)
            }
            size = CGSize(width: maxWidth, height: y + lineHeight)
        }
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

// MARK: - Trademark symbol helper

extension String {
    /// Returns a Text where ® and © are rendered as small superscripts
    /// matching the visual weight of the surrounding font.
    func trademarked(font mainFont: Font, symbolSize: CGFloat, symbolOffset: CGFloat) -> Text {
        var result = Text("")
        var buffer = ""
        for ch in self {
            if ch == "®" || ch == "©" {
                if !buffer.isEmpty {
                    result = result + Text(buffer).font(mainFont)
                    buffer = ""
                }
                result = result + Text(String(ch))
                    .font(.system(size: symbolSize))
                    .baselineOffset(symbolOffset)
            } else {
                buffer.append(ch)
            }
        }
        if !buffer.isEmpty {
            result = result + Text(buffer).font(mainFont)
        }
        return result
    }
}
