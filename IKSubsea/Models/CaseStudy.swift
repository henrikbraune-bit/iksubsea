import Foundation

struct CaseStudy: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let location: String
    let region: String
    let waterDepth: String?
    let client: String?
    let year: Int?
    let domain: ProductDomain
    let problemSummary: String
    let solution: String
    let outcome: String
    let productsUsed: [String]
    let relatedProductIds: [UUID]
    let tags: [String]
}

struct CaseStudyLibrary: Codable {
    let caseStudies: [CaseStudy]
}
