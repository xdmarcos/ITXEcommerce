//
//  CatalogGridView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 27/3/26.
//

import SwiftUI

struct CatalogGridView: View {
    var viewModel: CatalogViewModel

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: viewModel.columnCount)
    }

    var body: some View {
        if viewModel.filteredProducts.isEmpty,
           let category = viewModel.selectedCategory,
           viewModel.firstLoadCompleted {
            ContentUnavailableView(
                "No Products",
                systemImage: "tag.slash",
                description: Text("There are no products in \(category.displayName).")
            )
        } else {
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(viewModel.filteredProducts) { product in
                        NavigationLink(value: product) {
                            ProductCardView(
                                title: product.title,
                                brand: product.brand,
                                category: product.category,
                                price: product.price,
                                imageURL: URL(string: product.thumbnail),
                                isCompact: viewModel.columnCount == 3
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    if viewModel.hasMore && viewModel.firstLoadCompleted {
                        Color.clear
                            .frame(height: 1)
                            .onAppear { viewModel.loadNextPage() }
                    }
                }
                .padding(12)
            }
            .scrollIndicators(.hidden)
        }
    }
}
