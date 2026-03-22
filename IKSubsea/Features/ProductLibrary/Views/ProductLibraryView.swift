import SwiftUI

struct ProductLibraryView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var vm = ProductLibraryViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var filtered: [Product] {
        vm.filteredProducts(coordinator.dataService.products)
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Domain filter
                FilterChipBar(
                    title: "Category",
                    items: ProductDomain.allCases,
                    selected: $vm.selectedDomain
                )

                // Install method filter
                FilterChipBar(
                    title: "Installation",
                    items: InstallMethod.allCases,
                    selected: $vm.selectedInstallMethod
                )

                // Result count
                Text("\(filtered.count) product\(filtered.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(Color.iksGrey)

                if filtered.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Products Found",
                        message: "Try adjusting your filters or search term."
                    )
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(filtered) { product in
                            Button {
                                coordinator.libraryPath.append(
                                    ProductLibraryRoute.productDetail(productId: product.id)
                                )
                            } label: {
                                ProductCard(product: product)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle("Product Library")
        .searchable(text: $vm.searchText, prompt: "Search products or issues...")
        .background(Color.iksNavy.ignoresSafeArea())
    }
}

// Make enums work with FilterChipBar (needs CustomStringConvertible)
extension ProductDomain: CustomStringConvertible {
    public var description: String { rawValue }
}
extension InstallMethod: CustomStringConvertible {
    public var description: String { rawValue }
}
