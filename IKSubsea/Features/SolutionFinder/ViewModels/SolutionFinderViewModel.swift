import Foundation
import Observation

@Observable
final class SolutionFinderViewModel {

    var selectedCategoryId: UUID? = nil

    func reset() {
        selectedCategoryId = nil
    }
}
