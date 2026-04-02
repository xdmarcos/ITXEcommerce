//
//  NullCartRepository.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 2/4/26.
//

import Foundation

final class NullCartRepository: CartRepositoryProtocol {
    func fetchItems() throws -> [CartItem] { [] }
    func add(product: Product) throws {}
    func updateQuantity(_ item: CartItem, to quantity: Int) throws {}
    func remove(_ item: CartItem) throws {}
    func clear() throws {}
}
