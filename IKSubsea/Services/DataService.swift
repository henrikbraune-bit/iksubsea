import Foundation
import Observation

@Observable
final class DataService {

    var products: [Product] = []
    var problemCategories: [ProblemCategory] = []
    var caseStudies: [CaseStudy] = []
    var isLoaded = false

    init() {
        load()
    }

    func load() {
        products = loadJSON(filename: "products", type: ProductLibrary.self)?.products ?? []
        problemCategories = loadJSON(filename: "problemCategories", type: ProblemCategoryLibrary.self)?.categories ?? []
        caseStudies = loadJSON(filename: "caseStudies", type: CaseStudyLibrary.self)?.caseStudies ?? []
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
}
