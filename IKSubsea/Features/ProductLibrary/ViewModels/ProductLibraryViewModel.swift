import Foundation
import Observation

@Observable
final class ProductLibraryViewModel {

    var searchText: String = ""
    var selectedDomain: ProductDomain? = nil
    var selectedInstallMethod: InstallMethod? = nil

    func filteredProducts(_ products: [Product]) -> [Product] {
        products.filter { product in
            let matchesDomain = selectedDomain == nil || product.domain == selectedDomain
            let matchesInstall = selectedInstallMethod == nil
                || product.installationMethods.contains(selectedInstallMethod!)
            let matchesSearch = searchText.isEmpty
                || product.name.localizedCaseInsensitiveContains(searchText)
                || product.shortDescription.localizedCaseInsensitiveContains(searchText)
                || product.problemTags.contains {
                    $0.localizedCaseInsensitiveContains(searchText)
                }
            return matchesDomain && matchesInstall && matchesSearch
        }
    }
}
