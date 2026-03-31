//
//  CartRepository.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation
import SwiftData

@MainActor
final class CartRepository: CartRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchItems() async throws -> [CartItem] {
        try modelContext.fetch(FetchDescriptor<CartItem>())
    }

    func add(product: Product) async throws {
        let items = try await fetchItems()
        if let existing = items.first(where: { $0.product?.productId == product.productId }) {
            existing.quantity += 1
        } else {
            modelContext.insert(CartItem(product: product))
        }
        try modelContext.save()
    }

    func updateQuantity(_ item: CartItem, to quantity: Int) async throws {
        item.quantity = quantity
        try modelContext.save()
    }

    func remove(_ item: CartItem) async throws {
        modelContext.delete(item)
        try modelContext.save()
    }

    func clear() async throws {
        try await fetchItems().forEach { modelContext.delete($0) }
        try modelContext.save()
    }
}
