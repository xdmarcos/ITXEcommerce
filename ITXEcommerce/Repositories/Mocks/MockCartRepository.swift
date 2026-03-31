//
//  MockCartRepository.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

final class MockCartRepository: CartRepositoryProtocol {
    private(set) var storedItems: [CartItem] = []

    func fetchItems() async throws -> [CartItem] {
        storedItems
    }

    func add(product: Product) async throws {
        if let existing = storedItems.first(where: { $0.product?.productId == product.productId }) {
            existing.quantity += 1
        } else {
            storedItems.append(CartItem(product: product))
        }
    }

    func updateQuantity(_ item: CartItem, to quantity: Int) async throws {
        item.quantity = quantity
    }

    func remove(_ item: CartItem) async throws {
        storedItems.removeAll { $0 === item }
    }

    func clear() async throws {
        storedItems.removeAll()
    }
}
