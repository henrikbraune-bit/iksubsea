import Foundation

// MARK: - Enums

enum AddonCategory: String, Codable, CaseIterable, Hashable {
    case torqueTools   = "torque_tools"
    case frames        = "frames"
    case rovSkids      = "rov_skids"
    case valvePacks    = "valve_packs"
    case diverTools    = "diver_tools"
    case testEquipment = "test_equipment"
    case accessories   = "accessories"

    var displayName: String {
        switch self {
        case .torqueTools:   return "Torque Tools"
        case .frames:        return "Installation Frames"
        case .rovSkids:      return "ROV Skids"
        case .valvePacks:    return "Valve & HPU Packs"
        case .diverTools:    return "Diver Tools"
        case .testEquipment: return "Test Equipment"
        case .accessories:   return "Accessories"
        }
    }

    var icon: String {
        switch self {
        case .torqueTools:   return "wrench.adjustable.fill"
        case .frames:        return "square.3.layers.3d"
        case .rovSkids:      return "cube.fill"
        case .valvePacks:    return "gauge.with.needle.fill"
        case .diverTools:    return "figure.wave"
        case .testEquipment: return "chart.xyaxis.line"
        case .accessories:   return "link"
        }
    }
}

enum AddonAvailability: String, Codable {
    case rental   = "rental"
    case purchase = "purchase"
    case both     = "both"

    var displayLabel: String {
        switch self {
        case .rental:   return "Rental"
        case .purchase: return "Purchase"
        case .both:     return "Rental & Purchase"
        }
    }
}

// MARK: - Addon

struct Addon: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let shortDescription: String
    let fullDescription: String
    let category: AddonCategory
    let availability: AddonAvailability
    let typicalRentalDuration: String?   // e.g. "Per day / Per week"
    let depthRatingMeters: Int?
    let specs: [SpecItem]
    let standards: [String]
    let compatibleProductTags: [String]  // matches Product.problemTags
    let installationMethods: [InstallMethod]
    let isEmergencyStock: Bool           // available on short notice
}

struct AddonLibrary: Codable {
    let addons: [Addon]
}
