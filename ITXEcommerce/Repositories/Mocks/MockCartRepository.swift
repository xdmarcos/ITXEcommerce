//
//  MockCartRepository.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

final class MockCartRepository: CartRepositoryProtocol {
    private(set) var storedItems: [CartItem] = []

    func fetchItems() throws -> [CartItem] {
        storedItems
    }

    func add(product: Product, size: ProductSize, variantId: String) throws {
        if let existing = storedItems.first(where: {
            $0.product?.productId == product.productId &&
            $0.selectedSize == size &&
            $0.selectedVariantId == variantId
        }) {
            existing.quantity += 1
        } else {
            storedItems.append(CartItem(product: product, selectedSize: size, selectedVariantId: variantId))
        }
    }

    func updateQuantity(_ item: CartItem, to quantity: Int) throws {
        item.quantity = quantity
    }

    func remove(_ item: CartItem) throws {
        storedItems.removeAll { $0 === item }
    }

    func clear() throws {
        storedItems.removeAll()
    }
}
