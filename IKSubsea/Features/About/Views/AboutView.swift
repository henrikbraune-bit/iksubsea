import SwiftUI

struct AboutView: View {

    let stats: [(String, String, String)] = [
        ("500+",    "Completed Projects",  "checkmark.seal.fill"),
        ("39",      "Years of Experience", "calendar.badge.clock"),
        ("85%",     "International Revenue","globe"),
        ("13+",     "Named Products",      "square.grid.3x3.fill"),
    ]

    let accreditations = [
        "DNV Type Approved",
        "DNVGL-RP-F113 Compliant",
        "NORSOK Standards",
        "ISO 9001 Quality Management"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    // Logo hero
                    VStack(alignment: .leading, spacing: 14) {
                        Image("IKSLogoWhite")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 260)
                            .padding(.bottom, 2)

                        Text("Engineer-to-Order Subsea Solutions")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.iksTeal)

                        Text("IK Subsea is a global provider of subsea repair, isolation, lifting, and structural integrity solutions. Founded in 1987 and headquartered in Norway, IK Subsea has completed over 500 projects for major operators worldwide.")
                            .font(.body)
                            .foregroundStyle(Color.iksGrey)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(stats, id: \.0) { stat in
                            VStack(spacing: 6) {
                                Image(systemName: stat.2)
                                    .font(.title2)
                                    .foregroundStyle(Color.iksTeal)
                                Text(stat.0)
                                    .font(.title.weight(.bold))
                                    .foregroundStyle(Color.iksWhite)
                                Text(stat.1)
                                    .font(.caption)
                                    .foregroundStyle(Color.iksGrey)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .iksCard()
                        }
                    }

                    // Accreditations
                    VStack(alignment: .leading, spacing: 12) {
                        IKSSectionHeader(title: "Certifications & Standards")
                        ForEach(accreditations, id: \.self) { acc in
                            Label(acc, systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(Color.iksWhite)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(Color.iksTeal, Color.iksWhite)
                        }
                    }

                    // Contact
                    VStack(alignment: .leading, spacing: 12) {
                        IKSSectionHeader(title: "Get in Touch")

                        contactRow(icon: "envelope.fill", label: "sales@iksubsea.com") {
                            if let url = URL(string: "mailto:sales@iksubsea.com") {
                                UIApplication.shared.open(url)
                            }
                        }

                        contactRow(icon: "phone.fill", label: "+47 56 33 55 33") {
                            if let url = URL(string: "tel:+4756335533") {
                                UIApplication.shared.open(url)
                            }
                        }

                        contactRow(icon: "globe", label: "iksubsea.com") {
                            if let url = URL(string: "https://iksubsea.com") {
                                UIApplication.shared.open(url)
                            }
                        }

                        contactRow(icon: "network", label: "LinkedIn") {
                            if let url = URL(string: "https://www.linkedin.com/company/ik-subsea") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }

                    // App version footer
                    Text("IK Subsea Solutions App\nVersion 1.0 - March 2026")
                        .font(.caption)
                        .foregroundStyle(Color.iksGrey.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("About")
            .background(Color.iksNavy.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("IKSLogoWhite")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                }
            }
        }
    }

    @ViewBuilder
    private func contactRow(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(Color.iksTeal)
                    .frame(width: 24)
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(Color.iksWhite)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.iksGrey)
            }
            .padding(14)
            .iksCard()
        }
        .buttonStyle(.plain)
    }
}
