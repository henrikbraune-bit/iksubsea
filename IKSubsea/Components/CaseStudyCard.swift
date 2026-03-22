import SwiftUI

struct CaseStudyCard: View {
    let caseStudy: CaseStudy

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                DomainBadge(domain: caseStudy.domain)
                Spacer()
                if let year = caseStudy.year {
                    Text(String(year))
                        .font(.caption)
                        .foregroundStyle(Color.iksGrey)
                }
            }

            Text(caseStudy.title)
                .font(.headline)
                .foregroundStyle(Color.iksWhite)
                .lineLimit(2)

            HStack(spacing: 12) {
                Label(caseStudy.location, systemImage: "mappin.and.ellipse")
                if let depth = caseStudy.waterDepth {
                    Label(depth, systemImage: "arrow.down.to.line")
                }
            }
            .font(.caption)
            .foregroundStyle(Color.iksGrey)

            Text(caseStudy.problemSummary)
                .font(.subheadline)
                .foregroundStyle(Color.iksGrey)
                .lineLimit(2)
        }
        .padding(14)
        .iksCard()
    }
}
