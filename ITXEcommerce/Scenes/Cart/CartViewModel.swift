//
//  CartViewModel.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

@Observable
final class CartViewModel {
    private let repository: any CartRepositoryProtocol
    private(set) var items: [CartItem] = []
    private(set) var lastError: Error?

    init(repository: any CartRepositoryProtocol) {
        self.repository = repository
        reload()
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var totalPrice: Decimal {
        items.reduce(.zero) { total, item in
            total + (item.product?.price ?? 0) * Decimal(item.quantity)
        }
    }

    var currency: String {
        items.first?.product?.currency ?? "EUR"
    }

    func add(product: Product, size: ProductSize, variantId: String) {
        do {
            try repository.add(product: product, size: size, variantId: variantId)
            reload()
        } catch {
            lastError = error
        }
    }

    func increaseQuantity(_ item: CartItem) {
        do {
            try repository.updateQuantity(item, to: item.quantity + 1)
            reload()
        } catch {
            lastError = error
        }
    }

    func decreaseQuantity(_ item: CartItem) {
        do {
            if item.quantity > 1 {
                try repository.updateQuantity(item, to: item.quantity - 1)
            } else {
                try repository.remove(item)
            }
            reload()
        } catch {
            lastError = error
        }
    }

    func remove(_ item: CartItem) {
        do {
            try repository.remove(item)
            reload()
        } catch {
            lastError = error
        }
    }

    func onDelete(_ indexSet: IndexSet) {
        indexSet.map { items[$0] }.forEach { remove($0) }
    }

    func clearLastError() {
        lastError = nil
    }

    func checkout() {
        // TODO: implement checkout flow
    }

    private func reload() {
        do {
            items = try repository.fetchItems()
        } catch {
            lastError = error
        }
    }
}
