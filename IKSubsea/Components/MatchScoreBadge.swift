import SwiftUI

struct MatchScoreBadge: View {
    let score: Double   // 0.0 – 1.0

    var percent: Int { Int(score * 100) }

    var badgeColor: Color {
        switch score {
        case 0.70...: return Color.green
        case 0.45...: return Color.yellow
        default:      return Color.iksOrange
        }
    }

    var body: some View {
        Text("\(percent)% match")
            .font(.caption.weight(.bold))
            .foregroundStyle(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(badgeColor)
            .clipShape(Capsule())
    }
}
