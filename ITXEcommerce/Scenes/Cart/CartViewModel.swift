//
//  CartViewModel.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

@Observable
final class CartViewModel {
    private(set) var items: [CartItem] = []

    init(items: [CartItem] = []) {
        self.items = items
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var totalPrice: Decimal {
        items.reduce(.zero) { total, item in
            total + (item.product?.price ?? 0) * Decimal(item.quantity)
        }
    }

    var currency: String {
        items.first?.product?.currency ?? "EUR"
    }

    func add(product: Product, size: ProductSize, variantId: String) {
        if let index = items.firstIndex(where: {
            $0.product?.productId == product.productId &&
            $0.selectedSize == size &&
            $0.selectedVariantId == variantId
        }) {
            let item = items.remove(at: index)
            item.quantity += 1
            items.insert(item, at: index)
        } else {
            items.append(CartItem(product: product, selectedSize: size, selectedVariantId: variantId))
        }
    }

    func increaseQuantity(_ item: CartItem) {
        guard let index = items.firstIndex(where: { $0 === item }) else { return }

        let existing = items.remove(at: index)
        existing.quantity += 1
        items.insert(existing, at: index)
    }

    func decreaseQuantity(_ item: CartItem) {
        guard let index = items.firstIndex(where: { $0 === item }) else { return }

        if items[index].quantity > 1 {
            let existing = items.remove(at: index)
            existing.quantity -= 1
            items.insert(existing, at: index)
        } else {
            items.remove(at: index)
        }
    }

    func remove(_ item: CartItem) {
        items.removeAll { $0 === item }
    }

    func checkout() {
        // TODO
    }
}
