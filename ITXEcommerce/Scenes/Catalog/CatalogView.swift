//
//  CatalogView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
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
            makeCatalogContent()
        } detail: {
            ContentUnavailableView(
                "Select a Product",
                systemImage: "square.grid.3x3",
                description: Text("Browse the catalog and tap a product to see its details.")
            )
        }
    }
}

private extension CatalogView {
    var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: viewModel.columnCount)
    }

    func makeCatalogContent() -> some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(viewModel.filteredProducts) { product in
                    NavigationLink(value: product) {
                        ProductCardView(
                            name: product.name,
                            brand: product.brand,
                            price: product.price,
                            currency: product.currency,
                            imageURL: product.variants.first?.imageURLs.first.flatMap { URL(string: $0) }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Catalog [\(viewModel.filteredProducts.count)]")
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(product: product)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ColumnsSelectorButton(columnCount: viewModel.viewColumns) {
                    viewModel.columnsSelectorButtonOnTap()
                }

                CategorySelectorButton(
                    selectedCategory: $viewModel.selectedCategory,
                    allCases: viewModel.allCategories
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
                .environment(cartViewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Previews

#Preview("Catalog") {
    CatalogView(repository: MockProductRepository(products: Product.mockProducts))
        .environment(CartViewModel(repository: MockCartRepository()))
}
