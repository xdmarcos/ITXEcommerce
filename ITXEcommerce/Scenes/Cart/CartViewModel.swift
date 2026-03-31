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
    var firstLoadCompleted = false

    init(repository: any CartRepositoryProtocol) {
        self.repository = repository
        loadTask = Task { await self.reload() }
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var totalPrice: Decimal {
        items.reduce(.zero) { total, item in
            total + (item.product?.price ?? 0) * Decimal(item.quantity)
        }
    }

    let currency: String = "EUR"

    @discardableResult
    func onFirstAppear() -> Task<Void, Never> {
        if let loadTask { return loadTask }
        let task = Task {
            defer { firstLoadCompleted = true }
            await self.reload()
        }
        loadTask = task
        return task
    }

    @discardableResult
    func add(product: Product) -> Task<Void, Never> {
        Task {
            do {
                try await repository.add(product: product)
                await reload()
            } catch {
                lastError = error
            }
        }
    }

    @discardableResult
    func increaseQuantity(_ item: CartItem) -> Task<Void, Never> {
        Task {
            do {
                try await repository.updateQuantity(item, to: item.quantity + 1)
                await reload()
            } catch {
                lastError = error
            }
        }
    }

    @discardableResult
    func decreaseQuantity(_ item: CartItem) -> Task<Void, Never> {
        Task {
            do {
                if item.quantity > 1 {
                    try await repository.updateQuantity(item, to: item.quantity - 1)
                } else {
                    try await repository.remove(item)
                }
                await reload()
            } catch {
                lastError = error
            }
        }
    }

    @discardableResult
    func remove(_ item: CartItem) -> Task<Void, Never> {
        Task {
            do {
                try await repository.remove(item)
                await reload()
            } catch {
                lastError = error
            }
        }
    }

    @discardableResult
    func onDelete(_ indexSet: IndexSet) -> Task<Void, Never> {
        let itemsToDelete = indexSet.map { items[$0] }
        return Task {
            for item in itemsToDelete {
                await remove(item).value
            }
        }
    }

    func clearLastError() {
        lastError = nil
    }

    func checkout() {
        // TODO: implement checkout flow
    }

    private func reload() async {
        do {
            items = try await repository.fetchItems()
        } catch {
            lastError = error
        }
    }
}
