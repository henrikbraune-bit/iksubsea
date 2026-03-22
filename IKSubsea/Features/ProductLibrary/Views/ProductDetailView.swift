import SwiftUI

struct ProductDetailView: View {

    @Environment(AppCoordinator.self) private var coordinator
    let product: Product

    var relatedCaseStudies: [CaseStudy] {
        coordinator.dataService.caseStudies(for: product)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Hero header
                VStack(alignment: .leading, spacing: 10) {
                    DomainBadge(domain: product.domain)
                    Text(product.name)
                        .font(.title.weight(.bold))
                        .foregroundStyle(Color.iksWhite)
                    if product.isEmergencyCapable {
                        Label("Emergency deployment capability", systemImage: "bolt.fill")
                            .font(.subheadline)
                            .foregroundStyle(Color.iksOrange)
                    }
                }

                // Full description
                VStack(alignment: .leading, spacing: 8) {
                    IKSSectionHeader(title: "Overview")
                    Text(product.fullDescription)
                        .font(.body)
                        .foregroundStyle(Color.iksWhite)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Specifications table
                if !product.specs.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        IKSSectionHeader(title: "Technical Specifications")
                        VStack(spacing: 0) {
                            ForEach(Array(product.specs.enumerated()), id: \.offset) { idx, spec in
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.iksTeal.opacity(0.2), lineWidth: 1)
                        )
                    }
                }

                // Installation methods
                VStack(alignment: .leading, spacing: 8) {
                    IKSSectionHeader(title: "Installation Method")
                    HStack(spacing: 8) {
                        ForEach(product.installationMethods, id: \.self) { method in
                            Label(method.displayLabel, systemImage: method == .rov ? "robot" : "figure.wave")
                                .font(.subheadline)
                                .foregroundStyle(Color.iksTeal)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .overlay(Capsule().strokeBorder(Color.iksTeal.opacity(0.5), lineWidth: 1))
                        }
                    }
                }

                // Certifications
                if !product.certifications.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        IKSSectionHeader(title: "Certifications")
                        FlowLayout(spacing: 8) {
                            ForEach(product.certifications, id: \.self) { cert in
                                Text(cert)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Color.iksWhite)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.iksNavyMid)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .strokeBorder(Color.iksTeal.opacity(0.4), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }

                // Related case studies
                if !relatedCaseStudies.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        IKSSectionHeader(title: "Case Studies")
                        ForEach(relatedCaseStudies) { cs in
                            CaseStudyCard(caseStudy: cs)
                        }
                    }
                }

                // CTA
                Button {
                    let subject = "Enquiry: \(product.name)"
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "mailto:sales@iksubsea.com?subject=\(subject)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Enquire About This Product")
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
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.large)
        .background(Color.iksNavy.ignoresSafeArea())
    }
}
