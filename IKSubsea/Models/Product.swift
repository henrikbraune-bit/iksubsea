import Foundation

// MARK: - Enums

enum ProductDomain: String, Codable, CaseIterable, Hashable {
    case repair = "Subsea Repair"
    case isolation = "Isolation & Plugging"
    case lifting = "Lifting & Handling"
    case tooling = "Custom Tooling"
    case structural = "Structural Integrity"
}

enum InstallMethod: String, Codable, CaseIterable {
    case rov = "ROV"
    case diver = "Diver"
    case both = "ROV or Diver"
}

enum Severity: String, Codable {
    case critical, high, medium, low
}

// MARK: - Product

struct SpecItem: Codable, Hashable {
    let label: String
    let value: String
}

struct Product: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let shortDescription: String
    let fullDescription: String
    let domain: ProductDomain
    let problemTags: [String]
    let specs: [SpecItem]
    let installationMethods: [InstallMethod]
    let maxDepthMeters: Int?
    let certifications: [String]
    let relatedCaseStudyIds: [UUID]
    let isEmergencyCapable: Bool
}

struct ProductLibrary: Codable {
    let products: [Product]
}
