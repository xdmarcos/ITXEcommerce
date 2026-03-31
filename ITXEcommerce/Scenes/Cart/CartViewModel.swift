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
        try? repository.add(product: product, size: size, variantId: variantId)
        reload()
    }

    func increaseQuantity(_ item: CartItem) {
        try? repository.updateQuantity(item, to: item.quantity + 1)
        reload()
    }

    func decreaseQuantity(_ item: CartItem) {
        if item.quantity > 1 {
            try? repository.updateQuantity(item, to: item.quantity - 1)
        } else {
            try? repository.remove(item)
        }
        reload()
    }

    func remove(_ item: CartItem) {
        try? repository.remove(item)
        reload()
    }

    func onDelete(_ indexSet: IndexSet) {
        indexSet.map { items[$0] }.forEach { remove($0) }
    }

    func checkout() {
        // TODO: implement checkout flow
    }

    private func reload() {
        items = (try? repository.fetchItems()) ?? []
    }
}
