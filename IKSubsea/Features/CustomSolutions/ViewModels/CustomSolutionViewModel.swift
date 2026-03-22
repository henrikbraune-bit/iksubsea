import Foundation
import Observation
import SwiftUI

@Observable
final class CustomSolutionViewModel {

    var challengeDescription: String = ""
    var infrastructureType: String = ""
    var waterDepthMeters: Double = 0
    var operatingPressureBar: String = ""
    var urgency: UrgencyLevel = .planned
    var contactName: String = ""
    var contactCompany: String = ""
    var contactEmail: String = ""

    var showMailComposer = false
    var showValidationAlert = false

    enum UrgencyLevel: String, CaseIterable {
        case emergency = "Emergency (24-48 hrs)"
        case urgent    = "Urgent (1-2 weeks)"
        case planned   = "Planned (months)"
    }

    var isFormValid: Bool {
        !challengeDescription.isEmpty && !contactEmail.isEmpty
    }

    func buildEmailBody() -> String {
        """
        IK Subsea Custom Solution Enquiry

        Contact: \(contactName.isEmpty ? "Not provided" : contactName)
        Company: \(contactCompany.isEmpty ? "Not provided" : contactCompany)
        Email: \(contactEmail)

        Challenge Description:
        \(challengeDescription)

        Infrastructure Type: \(infrastructureType.isEmpty ? "Not specified" : infrastructureType)
        Water Depth: \(waterDepthMeters == 0 ? "Not specified" : "\(Int(waterDepthMeters))m")
        Operating Pressure: \(operatingPressureBar.isEmpty ? "Not specified" : "\(operatingPressureBar) bar")
        Urgency: \(urgency.rawValue)
        """
    }

    func reset() {
        challengeDescription = ""
        infrastructureType = ""
        waterDepthMeters = 0
        operatingPressureBar = ""
        urgency = .planned
        contactName = ""
        contactCompany = ""
        contactEmail = ""
    }
}
