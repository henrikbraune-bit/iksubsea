import SwiftUI

struct AddonDetailView: View {

    let addon: Addon
    @Environment(\.dismiss) private var dismiss

    var availabilityColor: Color {
        switch addon.availability {
        case .rental:   return Color.iksTeal
        case .purchase: return Color.iksSeaGreen
        case .both:     return Color.iksOrange
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Hero header
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: addon.category.icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.iksTeal)
                            Text(addon.category.displayName.uppercased())
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.iksTeal)
                        }

                        Text(addon.name)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.iksWhite)

                        HStack(spacing: 8) {
                            // Availability badge
                            HStack(spacing: 4) {
                                Image(systemName: addon.availability == .rental ? "clock.arrow.circlepath" : addon.availability == .purchase ? "bag.fill" : "arrow.left.arrow.right")
                                    .font(.caption)
                                Text(addon.availability.displayLabel)
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(availabilityColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .overlay(Capsule().strokeBorder(availabilityColor.opacity(0.5), lineWidth: 1))

                            // Fast-track badge
                            if addon.isEmergencyStock {
                                HStack(spacing: 4) {
                                    Image(systemName: "bolt.fill")
                                        .font(.caption)
                                    Text("Fast Track Available")
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(Color.iksOrange)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .overlay(Capsule().strokeBorder(Color.iksOrange.opacity(0.5), lineWidth: 1))
                            }
                        }

                        // Install methods
                        HStack(spacing: 6) {
                            ForEach(addon.installationMethods, id: \.self) { method in
                                Label(method.displayLabel, systemImage: method == .rov ? "robot" : "figure.wave")
                                    .font(.caption)
                                    .foregroundStyle(Color.iksGrey)
                            }
                        }
                    }

                    // Full description
                    VStack(alignment: .leading, spacing: 8) {
                        IKSSectionHeader(title: "Overview")
                        Text(addon.fullDescription)
                            .font(.body)
                            .foregroundStyle(Color.iksWhite)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Specs
                    if !addon.specs.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            IKSSectionHeader(title: "Technical Specifications")
                            VStack(spacing: 0) {
                                ForEach(Array(addon.specs.enumerated()), id: \.offset) { idx, spec in
                                    HStack {
                                        Text(spec.label)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(Color.iksGrey)
                                            .frame(maxWidth: 160, alignment: .leading)
                                        Spacer()
                                        Text(spec.value)
                                            .font(.subheadline)
                                            .foregroundStyle(Color.iksWhite)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 14)
                                    .background(idx.isMultiple(of: 2) ? Color.iksNavyMid : Color.iksNavy)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.iksTeal.opacity(0.2), lineWidth: 1))
                        }
                    }

                    // Rental info
                    if let rentalDuration = addon.typicalRentalDuration {
                        VStack(alignment: .leading, spacing: 8) {
                            IKSSectionHeader(title: "Rental Information")
                            HStack(spacing: 10) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundStyle(Color.iksTeal)
                                Text(rentalDuration)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.iksWhite)
                            }
                            .padding(14)
                            .background(Color.iksNavyMid.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.iksTeal.opacity(0.2), lineWidth: 1))

                            Text("All rental items are shipped pre-tested with calibration documentation. Contact us for current availability and lead times.")
                                .font(.caption)
                                .foregroundStyle(Color.iksGrey)
                        }
                    }

                    // Depth rating
                    if let depth = addon.depthRatingMeters {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.down.to.line")
                                .foregroundStyle(Color.iksTeal)
                            Text("Rated to \(depth)m water depth")
                                .font(.subheadline)
                                .foregroundStyle(Color.iksWhite)
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.iksNavyMid.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.iksTeal.opacity(0.2), lineWidth: 1))
                    }

                    // Standards
                    if !addon.standards.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            IKSSectionHeader(title: "Standards & Compliance")
                            FlowLayout(spacing: 8) {
                                ForEach(addon.standards, id: \.self) { standard in
                                    Label(standard, systemImage: "checkmark.seal.fill")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(Color.iksWhite)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.iksNavyMid)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color.iksTeal.opacity(0.4), lineWidth: 1))
                                }
                            }
                        }
                    }

                    // CTAs
                    VStack(spacing: 10) {
                        // Primary: Enquire
                        Button {
                            let subject = "Add-on Enquiry: \(addon.name)"
                                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            let body = "I would like to enquire about \(addon.availability == .rental ? "renting" : "purchasing") the \(addon.name)."
                                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            if let url = URL(string: "mailto:sales@iksubsea.com?subject=\(subject)&body=\(body)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "envelope")
                                Text(addon.availability == .rental ? "Enquire to Hire" : addon.availability == .purchase ? "Enquire to Purchase" : "Enquire Now")
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundStyle(Color.iksNavy)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.iksTeal)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Secondary: Call
                        Button {
                            if let url = URL(string: "tel:+4756335533") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "phone")
                                Text("Call +47 56 33 55 33")
                                Spacer()
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.iksTeal)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.iksTeal.opacity(0.5), lineWidth: 1.5))
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle(addon.name)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.iksNavy.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.iksGrey)
                            .font(.title3)
                    }
                }
            }
        }
    }
}
