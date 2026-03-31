//
//  ProductDetailView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct ProductDetailView: View {
    @State private var viewModel: ProductDetailViewModel
    @Environment(CartViewModel.self) private var cartViewModel

    init(product: Product) {
        _viewModel = State(wrappedValue: ProductDetailViewModel(product: product))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                makeImageGallery()
                makeInfoSection()
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                makeMetaSection()
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                makeAddToCartButton()
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
                    viewModel.cartButtonOnTap()
                }
            }
        }
        .sheet(isPresented: $viewModel.showCartDetail) {
            CartView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

private extension ProductDetailView {
    func makeImageGallery() -> some View {
        ImageGalleryView(
            images: viewModel.product.images,
            currentImageIndex: $viewModel.currentImageIndex
        )
        .frame(height: 460)
        .ignoresSafeArea(edges: .horizontal)
    }

    func makeInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(viewModel.product.category.displayName.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.secondary.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 6))

                Spacer()

                Text("Ref: \(viewModel.product.productId)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Text(viewModel.product.title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(viewModel.product.brand)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(viewModel.product.price, format: .currency(code: "EUR"))
                .font(.title3)
                .fontWeight(.medium)
                .padding(.top, 4)

            Text(viewModel.product.productDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func makeMetaSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 16) {
                Label(String(format: "%.1f", viewModel.product.rating), systemImage: "star.fill")
                    .font(.subheadline)
                    .foregroundStyle(.orange)

                if viewModel.product.discountPercentage > 0 {
                    Label(
                        String(format: "-%.0f%%", viewModel.product.discountPercentage),
                        systemImage: "tag.fill"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.green)
                }

                Label("\(viewModel.product.stock) in stock", systemImage: "shippingbox")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !viewModel.product.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.product.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.secondary.opacity(0.12))
                                .clipShape(.capsule)
                        }
                    }
                }
            }
        }
    }

    func makeAddToCartButton() -> some View {
        Button {
            cartViewModel.add(product: viewModel.product)
        } label: {
            Label("Add to Cart", systemImage: "cart.badge.plus")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProductDetailView(product: Product.mockProducts[0])
    }
    .environment(CartViewModel(repository: MockCartRepository()))
}
