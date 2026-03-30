//
//  CatalogView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct CatalogView: View {
    @State private var viewModel = CatalogViewModel()

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

    @ViewBuilder
    func makeCatalogContent() -> some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(viewModel.products) { product in
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
        .navigationTitle("Catalog")
        .navigationDestination(for: Product.self) { product in
            Text("Product Detail \(product.name)")
        }
    }
}

// MARK: - Previews

#Preview("Catalog") {
    CatalogView()
}
