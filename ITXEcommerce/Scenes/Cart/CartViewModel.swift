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
    private(set) var loadTask: Task<Void, Never>?
    private(set) var checkoutCompleted = false
    let currency = "EUR"
    var firstLoadCompleted = false
    var showCartDetail = false

    init(repository: any CartRepositoryProtocol) {
        self.repository = repository
        // to load carItems on app launch
        loadTask = Task { @MainActor in self.reload() }
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var totalPrice: Decimal {
        items.reduce(.zero) { total, item in
            total + (item.product?.price ?? 0) * Decimal(item.quantity)
        }
    }

    func cartButtonOnTap() {
        showCartDetail = true
    }

    func canAdd(_ product: Product) -> Bool {
        let inCart = items.first { $0.product?.productId == product.productId }?.quantity ?? 0
        return inCart < product.stock
    }

    func canIncrease(_ item: CartItem) -> Bool {
        guard let product = item.product else { return false }
        return item.quantity < product.stock
    }

    @discardableResult
    func onFirstAppear() -> Task<Void, Never> {
        if let loadTask { return loadTask }
        let task = Task { @MainActor in
            defer { self.firstLoadCompleted = true }
            self.reload()
        }
        loadTask = task
        return task
    }

    @discardableResult
    func add(product: Product) -> Task<Void, Never> {
        Task { @MainActor in
            guard self.canAdd(product) else { return }
            do {
                try self.repository.add(product: product)
                self.reload()
            } catch {
                self.lastError = error
            }
        }
    }

    @discardableResult
    func increaseQuantity(_ item: CartItem) -> Task<Void, Never> {
        Task { @MainActor in
            guard self.canIncrease(item) else { return }
            do {
                try self.repository.updateQuantity(item, to: item.quantity + 1)
                self.reload()
            } catch {
                self.lastError = error
            }
        }
    }

    @discardableResult
    func decreaseQuantity(_ item: CartItem) -> Task<Void, Never> {
        Task { @MainActor in
            do {
                if item.quantity > 1 {
                    try self.repository.updateQuantity(item, to: item.quantity - 1)
                } else {
                    try self.repository.remove(item)
                }
                self.reload()
            } catch {
                self.lastError = error
            }
        }
    }

    @discardableResult
    func remove(_ item: CartItem) -> Task<Void, Never> {
        Task { @MainActor in
            do {
                try self.repository.remove(item)
                self.reload()
            } catch {
                self.lastError = error
            }
        }
    }

    @discardableResult
    func onDelete(_ indexSet: IndexSet) -> Task<Void, Never> {
        let itemsToDelete = indexSet.map { items[$0] }
        return Task { @MainActor in
            for item in itemsToDelete {
                await self.remove(item).value
            }
        }
    }

    func clearLastError() {
        lastError = nil
    }

    func clearCheckoutCompleted() {
        checkoutCompleted = false
    }

    @discardableResult
    func checkout() -> Task<Void, Never> {
        Task { @MainActor in
            do {
                try self.repository.clear()
                self.reload()
                self.checkoutCompleted = true
            } catch {
                self.lastError = error
            }
        }
    }

    private func reload() {
        do {
            items = try repository.fetchItems()
        } catch {
            lastError = error
        }
    }
}
