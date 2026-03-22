import SwiftUI
import MessageUI

struct CustomSolutionView: View {

    @State private var vm = CustomSolutionViewModel()
    @State private var showMailSheet = false

    let infrastructureTypes = [
        "Pipeline", "Flexible Flowline", "Riser", "Umbilical",
        "Christmas Tree (XT)", "Conductor", "Platform Jacket",
        "PLEM / PLET", "Manifold", "Other"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // Intro
                VStack(alignment: .leading, spacing: 8) {
                    Text("Engineer-to-Order Solutions")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.iksWhite)
                    Text("IK Subsea designs and manufactures bespoke subsea solutions for unique challenges. Complete the form below and our engineering team will respond.")
                        .font(.subheadline)
                        .foregroundStyle(Color.iksGrey)
                }

                // Challenge description
                inputSection(title: "Describe the Challenge*") {
                    TextEditor(text: $vm.challengeDescription)
                        .frame(minHeight: 100)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(Color.iksWhite)
                        .font(.body)
                        .padding(10)
                        .background(Color.iksNavyMid)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.iksTeal.opacity(0.3), lineWidth: 1)
                        )
                }

                // Infrastructure type
                inputSection(title: "Infrastructure Type") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(infrastructureTypes, id: \.self) { type in
                                FilterChip(label: type, isSelected: vm.infrastructureType == type) {
                                    vm.infrastructureType = (vm.infrastructureType == type) ? "" : type
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }

                // Water depth
                inputSection(title: "Water Depth: \(Int(vm.waterDepthMeters))m") {
                    Slider(value: $vm.waterDepthMeters, in: 0...3500, step: 50)
                        .tint(Color.iksTeal)
                    HStack {
                        Text("Surface")
                        Spacer()
                        Text("3,500m")
                    }
                    .font(.caption)
                    .foregroundStyle(Color.iksGrey)
                }

                // Operating pressure
                inputSection(title: "Operating Pressure (bar, optional)") {
                    TextField("e.g. 250 bar", text: $vm.operatingPressureBar)
                        .keyboardType(.numbersAndPunctuation)
                        .iksTextField()
                }

                // Urgency
                inputSection(title: "Urgency") {
                    Picker("Urgency", selection: $vm.urgency) {
                        ForEach(CustomSolutionViewModel.UrgencyLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Divider().overlay(Color.iksNavyMid)

                // Contact
                IKSSectionHeader(title: "Your Contact Details")

                inputSection(title: "Name") {
                    TextField("Full name", text: $vm.contactName)
                        .iksTextField()
                }
                inputSection(title: "Company") {
                    TextField("Company name", text: $vm.contactCompany)
                        .iksTextField()
                }
                inputSection(title: "Email*") {
                    TextField("email@company.com", text: $vm.contactEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .iksTextField()
                }

                // Submit
                Button {
                    if vm.isFormValid {
                        showMailSheet = true
                    } else {
                        vm.showValidationAlert = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Send Enquiry to IK Subsea")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundStyle(vm.isFormValid ? Color.iksNavy : Color.iksGrey)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(vm.isFormValid ? Color.iksTeal : Color.iksNavyMid)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .animation(.easeInOut(duration: 0.15), value: vm.isFormValid)
                .padding(.bottom, 8)

                // Disclaimer
                Text("Your enquiry will be sent to sales@iksubsea.com. IK Subsea typically responds within one business day.")
                    .font(.caption)
                    .foregroundStyle(Color.iksGrey)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle("Custom Solutions")
        .background(Color.iksNavy.ignoresSafeArea())
        .alert("Required Fields", isPresented: $vm.showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please describe the challenge and provide your email address before submitting.")
        }
        .sheet(isPresented: $showMailSheet) {
            MailComposerView(
                toAddress: "sales@iksubsea.com",
                subject: "Custom Solution Enquiry",
                body: vm.buildEmailBody()
            ) { _ in
                showMailSheet = false
            }
        }
    }

    @ViewBuilder
    private func inputSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.iksGrey)
            content()
        }
    }
}

// MARK: - TextField Style

extension View {
    func iksTextField() -> some View {
        self
            .foregroundStyle(Color.iksWhite)
            .padding(12)
            .background(Color.iksNavyMid)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.iksTeal.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Mail Composer

struct MailComposerView: UIViewControllerRepresentable {
    let toAddress: String
    let subject: String
    let body: String
    let completion: (MFMailComposeResult) -> Void

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([toAddress])
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(completion: completion) }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let completion: (MFMailComposeResult) -> Void
        init(completion: @escaping (MFMailComposeResult) -> Void) { self.completion = completion }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true) { self.completion(result) }
        }
    }
}
