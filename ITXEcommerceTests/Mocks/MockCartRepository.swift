//
//  MockCartRepository.swift
//  ITXEcommerceTests
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation
@testable import ITXEcommerce

@MainActor
final class MockCartRepository: CartRepositoryProtocol {
    private(set) var storedItems: [CartItem] = []

    func fetchItems() throws -> [CartItem] {
        storedItems
    }

    func add(product: Product) throws {
        if let existing = storedItems.first(where: { $0.product?.productId == product.productId }) {
            existing.quantity += 1
        } else {
            storedItems.append(CartItem(product: product))
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
