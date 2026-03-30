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
                makeSizeSection()
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CartToolbarButton(itemCount: viewModel.cartItemCount) {
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

    func makeSizeSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Size")
                .font(.subheadline)
                .fontWeight(.medium)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(ProductSize.allCases, id: \.self) { size in
                        let isAvailable = viewModel.isSizeAvailable(size)
                        let isSelected = viewModel.selectedSize == size

                        Button {
                            viewModel.selectSize(size)
                        } label: {
                            Text(size.rawValue)
                                .font(.subheadline)
                                .fontWeight(isSelected ? .semibold : .regular)
                                .frame(minWidth: 52, minHeight: 44)
                                .background(isSelected ? Color.primary : Color.secondary.opacity(0.1))
                                .foregroundStyle(isSelected ? Color(.systemBackground) : isAvailable ? .primary : .primary.opacity(0.3))
                                .clipShape(.rect(cornerRadius: 8))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary.opacity(isAvailable ? 0 : 0.2))
                                }
                        }
                        .disabled(!isAvailable)
                        .accessibilityLabel("\(size.rawValue)\(isAvailable ? "" : ", unavailable")")
                    }
                }
            }
        }
    }

    func makeAddToCartButton() -> some View {
        Button {
            viewModel.addToCart()
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
