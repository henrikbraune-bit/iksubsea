import SwiftUI

struct RefinementView: View {

    @Environment(AppCoordinator.self) private var coordinator
    let category: ProblemCategory

    // Each question tracks which option was tapped (optional — user can skip)
    @State private var selections: [UUID: RefinementOption] = [:]

    var collectedTagSets: [[String]] {
        selections.values.map { $0.additionalTags }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // Category context header
                VStack(alignment: .leading, spacing: 6) {
                    Text(category.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.iksWhite)
                    Text("Refine your requirement for the best match.")
                        .font(.subheadline)
                        .foregroundStyle(Color.iksGrey)
                }

                // Refinement questions
                ForEach(category.refinementQuestions) { question in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(question.prompt)
                            .font(.headline)
                            .foregroundStyle(Color.iksWhite)

                        FlowLayout(spacing: 8) {
                            ForEach(question.options) { option in
                                let isSelected = selections[question.id]?.id == option.id
                                FilterChip(label: option.label, isSelected: isSelected) {
                                    if isSelected {
                                        selections.removeValue(forKey: question.id)
                                    } else {
                                        selections[question.id] = option
                                    }
                                }
                            }
                        }
                    }
                }

                // Find Solutions button
                Button {
                    coordinator.finderPath.append(
                        SolutionFinderRoute.results(
                            categoryId: category.id,
                            selectedTagSets: collectedTagSets
                        )
                    )
                } label: {
                    HStack {
                        Text("Find Solutions")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(Color.iksNavy)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.iksTeal)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle("Refine")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.iksNavy.ignoresSafeArea())
    }
}

// MARK: - Simple Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, maxY: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxY = max(maxY, y + rowHeight)
        }
        return CGSize(width: width, height: maxY)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX; y += rowHeight + spacing; rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
    }
}
