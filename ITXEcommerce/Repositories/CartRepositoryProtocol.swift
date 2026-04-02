//
//  CartRepositoryProtocol.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

protocol CartRepositoryProtocol: Sendable {
    func fetchItems() throws -> [CartItem]
    func add(product: Product) throws
    func updateQuantity(_ item: CartItem, to quantity: Int) throws
    func remove(_ item: CartItem) throws
    func clear() throws
}
