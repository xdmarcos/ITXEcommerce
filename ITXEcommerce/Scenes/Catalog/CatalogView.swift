//
//  CatalogView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 27/3/26.
//

import SwiftUI

struct CatalogView: View {
    @Environment(CartViewModel.self) private var cartViewModel
    @State private var viewModel: CatalogViewModel

    init(repository: any ProductRepositoryProtocol) {
        _viewModel = State(wrappedValue: CatalogViewModel(repository: repository))
    }

    var body: some View {
        NavigationSplitView {
            CatalogGridView(viewModel: viewModel)
                .task {
                    viewModel.onFirstAppear()
                }
                .navigationTitle(viewModel.filteredProducts.isEmpty ? "Catalog" : "Catalog [\(viewModel.filteredProducts.count)]")
                .navigationDestination(for: Product.self) { product in
                    ProductDetailView(product: product)
                        .id(product.productId)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        ColumnsSelectorButton(columnCount: viewModel.viewColumns) {
                            viewModel.columnsSelectorButtonOnTap()
                        }

                        MenuSelectorButton(
                            selectedCategory: $viewModel.selectedCategory,
                            allCases: viewModel.allCategories,
                            title: "Category",
                            resetTitle: "All",
                            checkedSystemName: "line.3.horizontal.decrease.circle.fill",
                            uncheckedSystemName: "line.3.horizontal.decrease.circle",
                            accessibilityLabel: "Filter by category"
                        )

                        MenuSelectorButton(
                            selectedCategory: $viewModel.selectedSort,
                            allCases: viewModel.allSortOption,
                            title: "Sort by",
                            resetTitle: "Default",
                            checkedSystemName: "arrow.up.arrow.down.square.fill",
                            uncheckedSystemName: "arrow.up.arrow.down.square",
                            accessibilityLabel: "Sort products by"
                        )
                    }
                    if #available(iOS 26.0, *) {
                        ToolbarSpacer(placement: .topBarTrailing)
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        CartToolbarButton(itemCount: cartViewModel.itemCount) {
                            viewModel.cartButtonOnTap()
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showCartDetail) {
                    CartView()
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
                .alert(
                    "Failed to load products",
                    isPresented: $viewModel.showErrorAlert,
                    actions: {
                        Button("Retry") { viewModel.reload() }
                        Button("OK", role: .cancel) { viewModel.clearLoadError() }
                    }, message: {
                        Text(viewModel.loadError?.localizedDescription ?? "")
                    }
                )
        } detail: {
            WelcomeView(
                title: "Select a Product",
                description: "Browse the catalog and tap a product to see its details.",
                systemImage: "square.grid.3x3"
            )
        }
    }
}

// MARK: - Previews

#Preview("Catalog") {
    CatalogView(repository: MockProductRepository(products: Product.mockProducts))
        .environment(CartViewModel(repository: MockCartRepository()))
}
