import SwiftUI

struct RootView: View {

    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator

        TabView(selection: $coordinator.selectedTab) {

            // MARK: - Solution Finder
            NavigationStack(path: $coordinator.finderPath) {
                SolutionFinderView()
                    .navigationDestination(for: SolutionFinderRoute.self) { route in
                        switch route {
                        case .refinement(let categoryId):
                            if let cat = coordinator.dataService.problemCategories.first(where: { $0.id == categoryId }) {
                                RefinementView(category: cat)
                            }
                        case .results(let categoryId, let selectedTagSets):
                            if let cat = coordinator.dataService.problemCategories.first(where: { $0.id == categoryId }) {
                                MatchedResultsView(category: cat, selectedTags: selectedTagSets)
                            }
                        case .freeSearch(let query):
                            FreeSearchResultsView(query: query)
                        case .productDetail(let productId):
                            if let product = coordinator.dataService.product(id: productId) {
                                ProductDetailView(product: product)
                            }
                        }
                    }
            }
            .tabItem {
                Label(AppTab.solutionFinder.rawValue, systemImage: AppTab.solutionFinder.icon)
            }
            .tag(AppTab.solutionFinder)

            // MARK: - Product Library
            NavigationStack(path: $coordinator.libraryPath) {
                ProductLibraryView()
                    .navigationDestination(for: ProductLibraryRoute.self) { route in
                        switch route {
                        case .productDetail(let productId):
                            if let product = coordinator.dataService.product(id: productId) {
                                ProductDetailView(product: product)
                            }
                        }
                    }
            }
            .tabItem {
                Label(AppTab.productLibrary.rawValue, systemImage: AppTab.productLibrary.icon)
            }
            .tag(AppTab.productLibrary)

            // MARK: - Case Studies
            NavigationStack(path: $coordinator.casesPath) {
                CaseStudiesView()
                    .navigationDestination(for: CaseStudiesRoute.self) { route in
                        switch route {
                        case .detail(let caseStudyId):
                            if let cs = coordinator.dataService.caseStudy(id: caseStudyId) {
                                CaseStudyDetailView(caseStudy: cs)
                            }
                        }
                    }
            }
            .tabItem {
                Label(AppTab.caseStudies.rawValue, systemImage: AppTab.caseStudies.icon)
            }
            .tag(AppTab.caseStudies)

            // MARK: - Add-ons
            AddonsView()
                .tabItem {
                    Label(AppTab.addons.rawValue, systemImage: AppTab.addons.icon)
                }
                .tag(AppTab.addons)

            // MARK: - Custom Solutions
            NavigationStack(path: $coordinator.customPath) {
                CustomSolutionView()
            }
            .tabItem {
                Label(AppTab.customSolutions.rawValue, systemImage: AppTab.customSolutions.icon)
            }
            .tag(AppTab.customSolutions)

            // MARK: - About
            AboutView()
                .tabItem {
                    Label(AppTab.about.rawValue, systemImage: AppTab.about.icon)
                }
                .tag(AppTab.about)
        }
        .tint(Color("IKSTeal"))
    }
}
