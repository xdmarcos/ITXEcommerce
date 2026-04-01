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

    @State private var stockLimitItem: CartItem?
    @State private var tooltipTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            Group {
                if cartViewModel.items.isEmpty {
                    makeEmptyState()
                } else {
                    makeCartList()
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
            .alert(
                "Cart error",
                isPresented: Binding(
                    get: { cartViewModel.lastError != nil },
                    set: { if !$0 { cartViewModel.clearLastError() } }
                ),
                presenting: cartViewModel.lastError
            ) { _ in
                Button("OK", role: .cancel) { cartViewModel.clearLastError() }
            } message: { error in
                Text(error.localizedDescription)
            }
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

private extension CartView {
    func triggerStockTooltip(for item: CartItem) {
        tooltipTask?.cancel()
        stockLimitItem = item
        tooltipTask = Task {
            try? await Task.sleep(for: .seconds(2))
            stockLimitItem = nil
        }
    }

    func makeEmptyState() -> some View {
        ContentUnavailableView(
            "Your Cart is Empty",
            systemImage: "cart",
            description: Text("Add products from the catalog to get started.")
        )
    }

    func makeCartList() -> some View {
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

            makeTotalSection()
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }

    func makeTotalSection() -> some View {
        VStack(spacing: 16) {
            Divider()

            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text(cartViewModel.totalPrice, format: .currency(code: cartViewModel.currency))
                    .font(.headline)
            }
            .padding(.horizontal)

            Button {
                cartViewModel.checkout()
            } label: {
                Text("Checkout")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - Preview

#Preview {
    CartView()
        .environment(CartViewModel(repository: MockCartRepository()))
}
