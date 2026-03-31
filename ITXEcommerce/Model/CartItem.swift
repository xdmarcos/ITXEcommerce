//
//  CartItem.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation
import SwiftData

@Model
final class CartItem {
    var quantity: Int
    var addedAt: Date

    var product: Product?

    init(product: Product, quantity: Int = 1) {
        self.product = product
        self.quantity = quantity
        self.addedAt = .now
    }
}
