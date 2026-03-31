//
//  CartRepository.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation
import SwiftData

final class CartRepository: CartRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchItems() throws -> [CartItem] {
        try modelContext.fetch(FetchDescriptor<CartItem>())
    }

    func add(product: Product, size: ProductSize, variantId: String) throws {
        let items = try fetchItems()
        if let existing = items.first(where: {
            $0.product?.productId == product.productId &&
            $0.selectedSize == size &&
            $0.selectedVariantId == variantId
        }) {
            existing.quantity += 1
        } else {
            modelContext.insert(CartItem(product: product, selectedSize: size, selectedVariantId: variantId))
        }
        try modelContext.save()
    }

    func updateQuantity(_ item: CartItem, to quantity: Int) throws {
        item.quantity = quantity
        try modelContext.save()
    }

    func remove(_ item: CartItem) throws {
        modelContext.delete(item)
        try modelContext.save()
    }

    func clear() throws {
        try fetchItems().forEach { modelContext.delete($0) }
        try modelContext.save()
    }
}
