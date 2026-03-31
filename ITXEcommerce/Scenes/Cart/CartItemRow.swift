//
//  CartItemRow.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct CartItemRow: View {
    let item: CartItem
    var decreaseQuantity: (CartItem) -> Void = { _ in }
    var increaseQuantity: (CartItem) -> Void = { _ in }

    init(
        item: CartItem,
        decreaseQuantity: @escaping (CartItem) -> Void = { _ in },
        increaseQuantity: @escaping (CartItem) -> Void = { _ in }
    ) {
        self.item = item
        self.decreaseQuantity = decreaseQuantity
        self.increaseQuantity = increaseQuantity
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: item.product?.thumbnail ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    Rectangle().foregroundStyle(.secondary.opacity(0.12))
                }
            }
            .frame(width: 72, height: 96)
            .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                if let product = item.product {
                    Text(product.brand)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(product.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(product.price, format: .currency(code: "EUR"))
                        .font(.subheadline)
                }

                HStack {
                    Spacer()
                    quantityControls
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 6)
    }

    private var quantityControls: some View {
        HStack(spacing: 0) {
            Button {
                decreaseQuantity(item)
            } label: {
                Image(systemName: "minus")
                    .frame(width: 32, height: 32)
            }
            .accessibilityLabel("Decrease quantity")

            Text("\(item.quantity)")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(minWidth: 28)
                .multilineTextAlignment(.center)

            Button {
                increaseQuantity(item)
            } label: {
                Image(systemName: "plus")
                    .frame(width: 32, height: 32)
            }
            .accessibilityLabel("Increase quantity")
        }
        .background(.secondary.opacity(0.1))
        .clipShape(.rect(cornerRadius: 8))
    }
}

#Preview {
    CartItemRow(
        item: CartItem(
            product: Product.mockProducts.first!, // swiftlint:disable:this force_unwrapping
            quantity: 2
        )
    )
}
