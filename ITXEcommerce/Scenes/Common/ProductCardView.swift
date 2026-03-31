//
//  ProductCardView.swift.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct ProductCardView: View {
    private let name: String
    private let brand: String
    private let price: Decimal
    private let currency: String
    private let imageURL: URL?

    init(name: String, brand: String, price: Decimal, currency: String, imageURL: URL? = nil) {
        self.name = name
        self.brand = brand
        self.price = price
        self.currency = currency
        self.imageURL = imageURL
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: imageURL) { phase in
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
                        }
                }
            }
            .aspectRatio(3/4, contentMode: .fit)
            .clipped()

            VStack(alignment: .leading, spacing: 3) {
                Text(brand)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(name)
                    .font(.callout)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                Text(price, format: .currency(code: currency))
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

#Preview("Card") {
    ProductCardView(
        name: "Slim Chino Trousers",
        brand: "Zara",
        price: 39.95,
        currency: "EUR",
        imageURL: nil
    )
    .frame(width: 180)
    .padding()
}
