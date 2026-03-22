import SwiftUI

struct RefinementView: View {

    @Environment(AppCoordinator.self) private var coordinator
    let category: ProblemCategory

    // Each question tracks which option was tapped (optional — user can skip)
    @State private var selections: [UUID: RefinementOption] = [:]

    var collectedTags: [String] {
        selections.values.flatMap { $0.additionalTags }
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
                            selectedTagSets: collectedTags
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

