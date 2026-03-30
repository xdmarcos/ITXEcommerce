//
//  ProductDetailView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct ProductDetailView: View {
    @State private var viewModel: ProductDetailViewModel

    init(product: Product) {
        viewModel = ProductDetailViewModel(product: product)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                makeImageGallery()
                makeInfoSection()
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                makeVariantSection()
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                makeAddToCartButton()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle(viewModel.product.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ProductDetailView {
    func makeImageGallery() -> some View {
        ImageGalleryView(
            images: viewModel.activeVariant?.imageURLs ?? [],
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

            Text(viewModel.product.name)
                .font(.title2)
                .fontWeight(.semibold)

            Text(viewModel.product.brand)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(viewModel.product.price, format: .currency(code: viewModel.product.currency))
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

    func makeVariantSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Colour")
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let name = viewModel.activeVariant?.colorName {
                    Text("— \(name)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(viewModel.product.variants) { variant in
                        Button {
                            viewModel.selectVariant(variant)
                        } label: {
                            Circle()
                                .fill(Color(hex: variant.colorHex))
                                .frame(width: 36, height: 36)
                                .overlay {
                                    Circle()
                                        .strokeBorder(
                                            viewModel.activeVariant?.id == variant.id ? Color.primary : Color.clear,
                                            lineWidth: 2
                                        )
                                        .padding(-4)
                                }
                        }
                        .accessibilityLabel(variant.colorName)
                    }
                }
                .padding(4)
            }
            .scrollIndicators(.hidden)
        }
    }

    func makeAddToCartButton() -> some View {
        Button {
            // TODO
        } label: {
            Label("Add to Cart", systemImage: "cart.badge.plus")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(viewModel.selectedSize == nil)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProductDetailView(product: Product.mockProducts[0])
    }
}
