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
    var selectedSize: ProductSize
    var selectedVariantId: String
    var addedAt: Date

    var product: Product?

    init(
        product: Product,
        selectedSize: ProductSize,
        selectedVariantId: String,
        quantity: Int = 1
    ) {
        self.product = product
        self.selectedSize = selectedSize
        self.selectedVariantId = selectedVariantId
        self.quantity = quantity
        self.addedAt = Date()
    }
}
