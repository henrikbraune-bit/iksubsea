import Foundation

struct RefinementOption: Codable, Identifiable, Hashable {
    let id: UUID
    let label: String
    let additionalTags: [String]
}

struct RefinementQuestion: Codable, Identifiable, Hashable {
    let id: UUID
    let prompt: String
    let options: [RefinementOption]
}

struct ProblemCategory: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let subtitle: String
    let icon: String            // SF Symbol name
    let colorName: String       // Asset colour name
    let severity: Severity
    let relatedTags: [String]
    let refinementQuestions: [RefinementQuestion]
}

struct ProblemCategoryLibrary: Codable {
    let categories: [ProblemCategory]
}
