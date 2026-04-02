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
    private(set) var loadTask: Task<Void, Never>?
    private(set) var checkoutCompleted = false
    let currency = "EUR"
    var firstLoadCompleted = false
    var showCartDetail = false

    var cartError: Error?

    @MainActor
    enum CartError: LocalizedError {
        case unknown(Error? = nil)
        case increaseQuantity(Error? = nil)
        case decreaseQuantity(Error? = nil)
        case add(Error? = nil)
        case remove(Error? = nil)
        case checkout(Error? = nil)
        case reload(Error? = nil)

        var errorDescription: LocalizedStringResource? {
            switch self {
            case .unknown: return "Unknown Error"
            case .increaseQuantity: return "Failed to increment"
            case .decreaseQuantity: return "Failed to decrement"
            case .add: return "Failed to add products"
            case .remove: return "Failed to remove products"
            case .checkout: return "Failed to Checkout products"
            case .reload: return "Failed to reload products"
            }
        }

        var recoverySuggestion: LocalizedStringResource? {

            switch self {
            case .unknown(let error):
                return LocalizedStringResource(stringLiteral: error?.localizedDescription ?? "")

            case .increaseQuantity(let error):
                let debugError = EnvironmentManager.shared.isStaging ? "\(error?.localizedDescription ?? "")" : ""
                return LocalizedStringResource(stringLiteral: "An unexpected error occurred. Please try again. \(debugError)")

            case .decreaseQuantity(let error):
                let debugError = EnvironmentManager.shared.isStaging ? "\(error?.localizedDescription ?? "")" : ""
                return LocalizedStringResource(stringLiteral: "An unexpected error occurred. Please try again. \(debugError)")

            case .add(let error):
                let debugError = EnvironmentManager.shared.isStaging ? "\(error?.localizedDescription ?? "")" : ""
                return LocalizedStringResource(stringLiteral: "A 'Add item' error occurred. \(debugError)")

            case .remove(let error):
                let debugError = EnvironmentManager.shared.isStaging ? "\(error?.localizedDescription ?? "")" : ""
                return LocalizedStringResource(stringLiteral: "A 'Remove item' error occurred. \(debugError)")

            case .checkout(let error):
                let debugError = EnvironmentManager.shared.isStaging ? "\(error?.localizedDescription ?? "")" : ""
                return LocalizedStringResource(stringLiteral: "A 'Checkout' error occurred. \(debugError)")

            case .reload(let error):
                let debugError = EnvironmentManager.shared.isStaging ? "\(error?.localizedDescription ?? "")" : ""
                return LocalizedStringResource(stringLiteral: "A 'Reload item' error occurred. \(debugError)")
            }
        }
    }

    init(repository: any CartRepositoryProtocol) {
        self.repository = repository
        // to load carItems on app launch
        loadTask = Task { @MainActor in reload() }
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
            defer { firstLoadCompleted = true }
            reload()
        }
        loadTask = task
        return task
    }

    @discardableResult
    func add(product: Product) -> Task<Void, Never> {
        Task { @MainActor in
            guard canAdd(product) else { return }
            do {
                try repository.add(product: product)
                reload()
            } catch {
                cartError = CartError.add(error)
            }
        }
    }

    @discardableResult
    func increaseQuantity(_ item: CartItem) -> Task<Void, Never> {
        Task { @MainActor in
            guard canIncrease(item) else { return }
            do {
                try repository.updateQuantity(item, to: item.quantity + 1)
                reload()
            } catch {
                cartError = CartError.increaseQuantity(error)
            }
        }
    }

    @discardableResult
    func decreaseQuantity(_ item: CartItem) -> Task<Void, Never> {
        Task { @MainActor in
            do {
                if item.quantity > 1 {
                    try repository.updateQuantity(item, to: item.quantity - 1)
                } else {
                    try repository.remove(item)
                }
                reload()
            } catch {
                cartError = CartError.decreaseQuantity(error)
            }
        }
    }

    @discardableResult
    func remove(_ item: CartItem) -> Task<Void, Never> {
        Task { @MainActor in
            do {
                try repository.remove(item)
                reload()
            } catch {
                cartError = CartError.remove(error)
            }
        }
    }

    @discardableResult
    func onDelete(_ indexSet: IndexSet) -> Task<Void, Never> {
        let itemsToDelete = indexSet.map { items[$0] }
        return Task { @MainActor in
            for item in itemsToDelete {
                await remove(item).value
            }
        }
    }

    func clearCartError() {
        cartError = nil
    }

    func clearCheckoutCompleted() {
        checkoutCompleted = false
    }

    @discardableResult
    func checkout() -> Task<Void, Never> {
        Task { @MainActor in
            do {
                try repository.clear()
                reload()
                checkoutCompleted = true
            } catch {
                cartError = CartError.checkout(error)
            }
        }
    }

    private func reload() {
        do {
            items = try repository.fetchItems()
        } catch {
            cartError = CartError.reload(error)
        }
    }
}
