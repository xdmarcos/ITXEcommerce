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
        // Temp: hardcoded image
        AsyncImage(url: URL(string: viewModel.product.variants[0].imageURLs[0])) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            default:
                Rectangle()
                    .foregroundStyle(.secondary.opacity(0.12))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.tertiary)
                            .font(.largeTitle)
                    }
            }
        }
    }
}

private extension ProductDetailView {
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
