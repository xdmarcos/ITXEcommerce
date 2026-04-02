//
//  CartView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct CartView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CartViewModel.self) private var cartViewModel

    var body: some View {
        NavigationStack {
            Group {
                if cartViewModel.items.isEmpty {
                    CartEmptyStateView()
                } else {
                    CartListContentView(cartViewModel: cartViewModel)
                }
            }
            .task {
                cartViewModel.onFirstAppear()
            }
            .navigationTitle("My Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .errorAlert(
                error: Binding(
                    get: { cartViewModel.cartError },
                    set: { if $0 != nil { cartViewModel.clearCartError() } }
                )
            )
            .alert(
                "Order Placed!",
                isPresented: Binding(
                    get: { cartViewModel.checkoutCompleted },
                    set: { if !$0 { cartViewModel.clearCheckoutCompleted() } }
                )
            ) {
                Button("OK") {
                    cartViewModel.clearCheckoutCompleted()
                    dismiss()
                }
            } message: {
                Text("Your order has been placed successfully. Thank you for shopping with us!")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CartView()
        .environment(CartViewModel(repository: NullCartRepository()))
}
