import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundStyle(Color.iksGrey)

            VStack(spacing: 6) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.iksWhite)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.iksGrey)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundStyle(Color.iksNavy)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.iksTeal)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}
