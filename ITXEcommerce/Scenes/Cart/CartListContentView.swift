//
//  CartListContentView.swift
//  ITXEcommerce
//

import SwiftUI

struct CartListContentView: View {
    var cartViewModel: CartViewModel

    @State private var stockLimitItem: CartItem?
    @State private var tooltipTask: Task<Void, Never>?

    var body: some View {
        List {
            ForEach(cartViewModel.items) { item in
                CartItemRow(
                    item: item,
                    showTooltip: stockLimitItem === item,
                    tooltip: "Max stock reached",
                    decreaseQuantity: { cartViewModel.decreaseQuantity($0) },
                    increaseQuantity: {
                        guard cartViewModel.canIncrease($0) else {
                            triggerStockTooltip(for: $0)
                            return
                        }
                        cartViewModel.increaseQuantity($0)
                    }
                )
            }
            .onDelete { cartViewModel.onDelete($0) }

            CartTotalSectionView(cartViewModel: cartViewModel)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }

    private func triggerStockTooltip(for item: CartItem) {
        tooltipTask?.cancel()
        stockLimitItem = item
        tooltipTask = Task {
            try? await Task.sleep(for: .seconds(2))
            stockLimitItem = nil
        }
    }
}
