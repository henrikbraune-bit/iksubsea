import Foundation

enum AppTab: String, CaseIterable, Hashable {
    case solutionFinder = "Solution Finder"
    case productLibrary = "Products"
    case caseStudies = "Case Studies"
    case customSolutions = "Custom"
    case about = "About"

    var icon: String {
        switch self {
        case .solutionFinder:  return "magnifyingglass"
        case .productLibrary:  return "square.grid.2x2"
        case .caseStudies:     return "doc.text"
        case .customSolutions: return "slider.horizontal.3"
        case .about:           return "info.circle"
        }
    }
}

enum SolutionFinderRoute: Hashable {
    case refinement(categoryId: UUID)
    case results(categoryId: UUID, selectedTagSets: [[String]])
    case productDetail(productId: UUID)
}

enum ProductLibraryRoute: Hashable {
    case productDetail(productId: UUID)
}

enum CaseStudiesRoute: Hashable {
    case detail(caseStudyId: UUID)
}
