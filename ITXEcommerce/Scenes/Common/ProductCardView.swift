//
//  ProductCardView.swift.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct ProductCardView: View {
    private let title: String
    private let brand: String
    private let category: ProductCategory
    private let price: Decimal
    private let imageURL: URL?
    private let isCompact: Bool

    init(
        title: String,
        brand: String,
        category: ProductCategory,
        price: Decimal,
        imageURL: URL? = nil,
        isCompact: Bool = false
    ) {
        self.title = title
        self.brand = brand
        self.category = category
        self.price = price
        self.imageURL = imageURL
        self.isCompact = isCompact
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .foregroundStyle(.secondary.opacity(0.12))
                .aspectRatio(3/4, contentMode: .fit)
                .overlay {
                    AsyncImage(url: imageURL) { phase in
                        if case .success(let image) = phase {
                            image.resizable().scaledToFit()
                        } else {
                            Image(systemName: "photo")
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .clipped()

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    if isCompact {
                        Circle()
                            .fill(category.color)
                            .frame(width: 8, height: 8)
                    } else {
                        Text(category.displayName)
                            .font(.caption)
                            .foregroundStyle(category.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(category.color.opacity(0.15))
                            .clipShape(.capsule)
                    }

                    Text(brand)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .lineLimit(2)

                Text(title)
                    .font(.callout)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                Text(price, format: .currency(code: "EUR"))
                    .font(.callout)
                    .foregroundStyle(.primary)
            }
            .padding(10)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.background)
        .clipShape(.rect(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Previews

#Preview("Card – Default") {
    ProductCardView(
        title: "Slim Chino Trousers",
        brand: "Zara",
        category: .tops,
        price: 39.95
    )
    .frame(width: 180)
    .padding()
}

#Preview("Card – Compact") {
    ProductCardView(
        title: "Slim Chino Trousers",
        brand: "Zara",
        category: .tops,
        price: 39.95,
        isCompact: true
    )
    .frame(width: 120)
    .padding()
}
