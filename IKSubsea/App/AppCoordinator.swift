import SwiftUI
import Observation

@Observable
final class AppCoordinator {

    var selectedTab: AppTab = .solutionFinder

    // Per-tab navigation paths
    var finderPath: NavigationPath = NavigationPath()
    var libraryPath: NavigationPath = NavigationPath()
    var casesPath: NavigationPath = NavigationPath()
    var customPath: NavigationPath = NavigationPath()

    let dataService = DataService()

    // Called when user taps the active tab icon — pops to root
    func resetTab(_ tab: AppTab) {
        switch tab {
        case .solutionFinder:  finderPath = NavigationPath()
        case .productLibrary:  libraryPath = NavigationPath()
        case .caseStudies:     casesPath = NavigationPath()
        case .customSolutions: customPath = NavigationPath()
        case .addons: break
        case .about: break
        }
    }

    // Route from Solution Finder results to Custom Solutions
    func routeToCustomSolutions() {
        selectedTab = .customSolutions
        customPath = NavigationPath()
    }
}
