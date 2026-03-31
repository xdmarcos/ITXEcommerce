//
//  CartRepositoryProtocol.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

@MainActor
protocol CartRepositoryProtocol {
    func fetchItems() async throws -> [CartItem]
    func add(product: Product, size: ProductSize, variantId: String) async throws
    func updateQuantity(_ item: CartItem, to quantity: Int) async throws
    func remove(_ item: CartItem) async throws
    func clear() async throws
}
