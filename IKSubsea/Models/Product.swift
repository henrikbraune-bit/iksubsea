import Foundation

// MARK: - Enums

enum ProductDomain: String, Codable, CaseIterable, Hashable {
    case repair = "repair"
    case isolation = "isolation"
    case lifting = "lifting"
    case tooling = "tooling"
    case structural = "structural"

    var displayName: String {
        switch self {
        case .repair:     return "Subsea Repair"
        case .isolation:  return "Isolation & Plugging"
        case .lifting:    return "Lifting & Handling"
        case .tooling:    return "Custom Tooling"
        case .structural: return "Structural Integrity"
        }
    }
}

enum InstallMethod: String, Codable, CaseIterable {
    case rov = "rov"
    case diver = "diver"
    case both = "both"

    var displayLabel: String {
        switch self {
        case .rov:   return "ROV"
        case .diver: return "Diver"
        case .both:  return "ROV or Diver"
        }
    }
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
