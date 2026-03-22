import SwiftUI

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.iksNavy : Color.iksWhite)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.iksTeal : Color.iksNavyMid)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(Color.iksTeal.opacity(isSelected ? 0 : 0.4), lineWidth: 1))
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

struct FilterChipBar<T: Hashable & CustomStringConvertible>: View {
    let title: String
    let items: [T]
    @Binding var selected: T?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.iksGrey)
                .textCase(.uppercase)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(label: "All", isSelected: selected == nil) {
                        selected = nil
                    }
                    ForEach(items, id: \.self) { item in
                        FilterChip(label: item.description, isSelected: selected == item) {
                            selected = (selected == item) ? nil : item
                        }
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }
}
