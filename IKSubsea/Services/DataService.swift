import Foundation
import Observation

@Observable
final class DataService {

    var products: [Product] = []
    var problemCategories: [ProblemCategory] = []
    var caseStudies: [CaseStudy] = []
    var addons: [Addon] = []
    var isLoaded = false

    init() {
        load()
    }

    func load() {
        products = loadJSON(filename: "products", type: ProductLibrary.self)?.products ?? []
        problemCategories = loadJSON(filename: "problemCategories", type: ProblemCategoryLibrary.self)?.categories ?? []
        caseStudies = loadJSON(filename: "caseStudies", type: CaseStudyLibrary.self)?.caseStudies ?? []
        addons = loadJSON(filename: "addons", type: AddonLibrary.self)?.addons ?? []
        isLoaded = true
    }

    private func loadJSON<T: Decodable>(filename: String, type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("[DataService] Could not find \(filename).json in bundle")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("[DataService] Failed to decode \(filename).json: \(error)")
            return nil
        }
    }

    // MARK: - Helpers

    func product(id: UUID) -> Product? {
        products.first { $0.id == id }
    }

    func caseStudy(id: UUID) -> CaseStudy? {
        caseStudies.first { $0.id == id }
    }

    func caseStudies(for product: Product) -> [CaseStudy] {
        caseStudies.filter { cs in
            product.relatedCaseStudyIds.contains(cs.id)
        }
    }

    func products(in domain: ProductDomain) -> [Product] {
        products.filter { $0.domain == domain }
    }

    func addon(id: UUID) -> Addon? {
        addons.first { $0.id == id }
    }

    func addons(for product: Product) -> [Addon] {
        let productTags = Set(product.problemTags)
        return addons
            .filter { addon in
                let addonTags = Set(addon.compatibleProductTags)
                return !addonTags.intersection(productTags).isEmpty
            }
            .sorted { $0.isEmergencyStock && !$1.isEmergencyStock }
    }

    func addons(in category: AddonCategory) -> [Addon] {
        addons.filter { $0.category == category }
    }
}
