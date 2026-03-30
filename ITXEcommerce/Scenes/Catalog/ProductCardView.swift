//
//  ProductCardView.swift.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct ProductCardView: View {
    let name: String
    let brand: String
    let price: Decimal
    let currency: String
    let imageURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
        .background(.background)
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
