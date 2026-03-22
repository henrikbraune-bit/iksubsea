import SwiftUI

struct SolutionFinderView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var vm = SolutionFinderViewModel()
    @State private var searchQuery: String = ""
    @FocusState private var searchFocused: Bool

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
                    Text("Describe your challenge or select a category below.")
                        .font(.subheadline)
                        .foregroundStyle(Color.iksGrey)
                }
                .padding(.top, 8)

                // AI Search box
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.iksTeal)

                        TextField("e.g. pipeline leak at 800m, emergency...", text: $searchQuery)
                            .font(.subheadline)
                            .foregroundStyle(Color.iksWhite)
                            .tint(Color.iksTeal)
                            .focused($searchFocused)
                            .submitLabel(.search)
                            .onSubmit { submitSearch() }

                        if !searchQuery.isEmpty {
                            Button {
                                searchQuery = ""
                                searchFocused = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.iksGrey)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.iksNavyMid.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                searchFocused ? Color.iksTeal : Color.iksTeal.opacity(0.25),
                                lineWidth: searchFocused ? 1.5 : 1
                            )
                    )

                    if !searchQuery.isEmpty {
                        Button { submitSearch() } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Find Solutions")
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .foregroundStyle(Color.iksNavy)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.iksTeal)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: searchQuery.isEmpty)

                // Divider with label
                HStack(spacing: 10) {
                    Rectangle()
                        .fill(Color.iksTeal.opacity(0.2))
                        .frame(height: 1)
                    Text("OR BROWSE BY CATEGORY")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.iksGrey)
                        .fixedSize()
                    Rectangle()
                        .fill(Color.iksTeal.opacity(0.2))
                        .frame(height: 1)
                }

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
        .onTapGesture { searchFocused = false }
    }

    private func submitSearch() {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        searchFocused = false
        coordinator.finderPath.append(SolutionFinderRoute.freeSearch(query: trimmed))
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
