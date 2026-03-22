import Foundation
import Observation

@Observable
final class CaseStudiesViewModel {

    var selectedDomain: ProductDomain? = nil
    var selectedRegion: String? = nil
    var searchText: String = ""

    func filteredStudies(_ studies: [CaseStudy]) -> [CaseStudy] {
        studies.filter { cs in
            let matchesDomain = selectedDomain == nil || cs.domain == selectedDomain
            let matchesRegion = selectedRegion == nil || cs.region == selectedRegion
            let matchesSearch = searchText.isEmpty
                || cs.title.localizedCaseInsensitiveContains(searchText)
                || cs.location.localizedCaseInsensitiveContains(searchText)
            return matchesDomain && matchesRegion && matchesSearch
        }
    }

    func regions(from studies: [CaseStudy]) -> [String] {
        Array(Set(studies.map { $0.region })).sorted()
    }
}
