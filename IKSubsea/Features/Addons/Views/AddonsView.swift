import SwiftUI

struct AddonsView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var selectedCategory: AddonCategory? = nil
    @State private var availabilityFilter: AddonAvailability? = nil
    @State private var selectedAddon: Addon? = nil

    var filteredAddons: [Addon] {
        coordinator.dataService.addons.filter { addon in
            let categoryMatch = selectedCategory == nil || addon.category == selectedCategory
            let availabilityMatch: Bool = {
                guard let filter = availabilityFilter else { return true }
                switch filter {
                case .rental:   return addon.availability == .rental || addon.availability == .both
                case .purchase: return addon.availability == .purchase || addon.availability == .both
                case .both:     return true
                }
            }()
            return categoryMatch && availabilityMatch
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Installation Add-ons")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(Color.iksWhite)
                        Text("Tooling and equipment to support your installation — available to rent or purchase.")
                            .font(.subheadline)
                            .foregroundStyle(Color.iksGrey)
                    }
                    .padding(.top, 8)

                    // Rental / Purchase toggle
                    HStack(spacing: 8) {
                        ForEach([nil, AddonAvailability.rental, AddonAvailability.purchase], id: \.self) { filter in
                            let label = filter == nil ? "All" : filter!.displayLabel
                            let isSelected = availabilityFilter == filter
                            Button {
                                availabilityFilter = filter
                            } label: {
                                Text(label)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(isSelected ? Color.iksNavy : Color.iksWhite)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(isSelected ? Color.iksTeal : Color.iksNavyMid.opacity(0.6))
                                    .clipShape(Capsule())
                                    .overlay(Capsule().strokeBorder(isSelected ? Color.clear : Color.iksTeal.opacity(0.3), lineWidth: 1))
                            }
                        }
                        Spacer()
                    }

                    // Category filter scrollable chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryChip(label: "All", icon: "square.grid.2x2", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            ForEach(AddonCategory.allCases, id: \.self) { cat in
                                CategoryChip(label: cat.displayName, icon: cat.icon, isSelected: selectedCategory == cat) {
                                    selectedCategory = (selectedCategory == cat) ? nil : cat
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                    }

                    // Results count
                    Text("\(filteredAddons.count) item\(filteredAddons.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(Color.iksGrey)

                    // Add-on cards
                    LazyVStack(spacing: 12) {
                        ForEach(filteredAddons) { addon in
                            Button {
                                selectedAddon = addon
                            } label: {
                                AddonCard(addon: addon)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if filteredAddons.isEmpty {
                        EmptyStateView(
                            icon: "wrench.and.screwdriver",
                            title: "No Items Found",
                            message: "Try adjusting your category or availability filters.",
                            actionTitle: nil,
                            action: nil
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.iksNavy.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("IKSLogoWhite")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                }
            }
            .sheet(item: $selectedAddon) { addon in
                AddonDetailView(addon: addon)
            }
        }
    }
}

// MARK: - Category Chip

private struct CategoryChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(isSelected ? Color.iksNavy : Color.iksWhite)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(isSelected ? Color.iksTeal : Color.iksNavyMid.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(isSelected ? Color.clear : Color.iksTeal.opacity(0.25), lineWidth: 1))
        }
    }
}

// MARK: - Addon Card

struct AddonCard: View {
    let addon: Addon

    var availabilityColor: Color {
        switch addon.availability {
        case .rental:   return Color.iksTeal
        case .purchase: return Color.iksSeaGreen
        case .both:     return Color.iksOrange
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    // Category badge
                    HStack(spacing: 5) {
                        Image(systemName: addon.category.icon)
                            .font(.caption2)
                        Text(addon.category.displayName.uppercased())
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(Color.iksTeal)

                    Text(addon.name)
                        .font(.headline)
                        .foregroundStyle(Color.iksWhite)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer()

                // Availability pill
                Text(addon.availability.displayLabel)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(availabilityColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .overlay(Capsule().strokeBorder(availabilityColor.opacity(0.5), lineWidth: 1))
            }

            Text(addon.shortDescription)
                .font(.subheadline)
                .foregroundStyle(Color.iksGrey)
                .lineLimit(2)

            // Key specs strip
            if !addon.specs.isEmpty {
                HStack(spacing: 12) {
                    ForEach(addon.specs.prefix(2), id: \.label) { spec in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(spec.label)
                                .font(.caption2)
                                .foregroundStyle(Color.iksGrey)
                            Text(spec.value)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.iksWhite)
                        }
                    }
                    Spacer()
                    if addon.isEmergencyStock {
                        Label("Fast Track", systemImage: "bolt.fill")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.iksOrange)
                    }
                }
            }

            // Install method chips
            HStack(spacing: 6) {
                ForEach(addon.installationMethods, id: \.self) { method in
                    Text(method.displayLabel)
                        .font(.caption2)
                        .foregroundStyle(Color.iksTeal)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .overlay(Capsule().strokeBorder(Color.iksTeal.opacity(0.4), lineWidth: 1))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.iksTeal)
            }
        }
        .padding(14)
        .iksCard()
    }
}
