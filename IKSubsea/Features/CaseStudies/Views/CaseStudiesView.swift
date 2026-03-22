import SwiftUI

struct CaseStudiesView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var vm = CaseStudiesViewModel()

    var filtered: [CaseStudy] {
        vm.filteredStudies(coordinator.dataService.caseStudies)
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                FilterChipBar(
                    title: "Domain",
                    items: ProductDomain.allCases,
                    selected: $vm.selectedDomain
                )

                let regions = vm.regions(from: coordinator.dataService.caseStudies)
                FilterChipBar(
                    title: "Region",
                    items: regions,
                    selected: $vm.selectedRegion
                )

                Text("\(filtered.count) case stud\(filtered.count == 1 ? "y" : "ies")")
                    .font(.caption)
                    .foregroundStyle(Color.iksGrey)

                if filtered.isEmpty {
                    EmptyStateView(
                        icon: "doc.text.magnifyingglass",
                        title: "No Case Studies Found",
                        message: "Adjust your filters to explore more projects."
                    )
                } else {
                    ForEach(filtered) { cs in
                        Button {
                            coordinator.casesPath.append(CaseStudiesRoute.detail(caseStudyId: cs.id))
                        } label: {
                            CaseStudyCard(caseStudy: cs)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle("Case Studies")
        .searchable(text: $vm.searchText, prompt: "Search by title or location...")
        .background(Color.iksNavy.ignoresSafeArea())
    }
}

// String already conforms to CustomStringConvertible in Swift stdlib
