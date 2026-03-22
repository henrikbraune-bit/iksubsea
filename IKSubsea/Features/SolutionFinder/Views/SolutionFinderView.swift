import SwiftUI

struct SolutionFinderView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var vm = SolutionFinderViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        @Bindable var coordinator = coordinator

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("What is the issue?")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Color.iksWhite)
                    Text("Select the primary challenge to find the right solution.")
                        .font(.subheadline)
                        .foregroundStyle(Color.iksGrey)
                }
                .padding(.top, 8)

                // Category grid
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(coordinator.dataService.problemCategories) { category in
                        Button {
                            coordinator.finderPath.append(
                                SolutionFinderRoute.refinement(categoryId: category.id)
                            )
                        } label: {
                            ProblemCategoryCardView(category: category)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.iksNavy.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("IKSLogoWhite")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
            }
        }
    }
}

// MARK: - Problem Category Card

private struct ProblemCategoryCardView: View {
    let category: ProblemCategory

    var severityColor: Color {
        switch category.severity {
        case .critical: return Color.iksOrange
        case .high:     return Color.iksOrange.opacity(0.8)
        case .medium:   return Color.iksTeal
        case .low:      return Color.iksSeaGreen
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(severityColor)
                Spacer()
                Circle()
                    .fill(severityColor)
                    .frame(width: 8, height: 8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                    .foregroundStyle(Color.iksWhite)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(category.subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.iksGrey)
                    .lineLimit(2)
            }

            HStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.iksTeal)
            }
        }
        .padding(16)
        .iksCard()
        .frame(minHeight: 140)
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}
