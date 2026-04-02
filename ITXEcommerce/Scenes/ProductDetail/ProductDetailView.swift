//
//  ProductDetailView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct ProductDetailView: View {
    @Environment(CartViewModel.self) private var cartViewModel
    @State private var viewModel: ProductDetailViewModel

    init(product: Product) {
        _viewModel = State(wrappedValue: ProductDetailViewModel(product: product))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ImageGalleryView(
                    images: viewModel.product.images,
                    currentImageIndex: $viewModel.currentImageIndex
                )
                .frame(height: 460)
                .ignoresSafeArea(edges: .horizontal)

                DetailInformationView(viewModel: viewModel)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                DetailMetadataView(viewModel: viewModel)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                let canAdd = cartViewModel.canAdd(viewModel.product)
                AddToCartButtonView(canAdd: canAdd) {
                    cartViewModel.add(product: viewModel.product)
                }
                .animation(.easeInOut, value: canAdd)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)

            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle(viewModel.product.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CartToolbarButton(itemCount: cartViewModel.itemCount) {
                    cartViewModel.cartButtonOnTap()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProductDetailView(product: Product.mockProducts[0])
    }
    .environment(CartViewModel(repository: NullCartRepository()))
}
