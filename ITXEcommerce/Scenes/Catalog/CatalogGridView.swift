//
//  CatalogGridView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 27/3/26.
//

import SwiftUI

struct CatalogGridView: View {
    @Bindable var viewModel: CatalogViewModel

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: viewModel.columnCount)
    }

    var body: some View {
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
                }
            }
            .padding(12)
        }
        .scrollIndicators(.hidden)
    }
}
