//
//  CartView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct CartView: View {
    @Environment(\.dismiss) private var dismiss

    private var viewModel: CartViewModel

    init(items: [CartItem] = []) {
        viewModel = CartViewModel(items: items)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty {
                    makeEmptyState()
                } else {
                    makeCartList()
                }
            }
            .navigationTitle("My Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

private extension CartView {
    func makeEmptyState() -> some View {
        ContentUnavailableView(
            "Your Cart is Empty",
            systemImage: "cart",
            description: Text("Add products from the catalog to get started.")
        )
    }

    func makeCartList() -> some View {
        List {
            ForEach(viewModel.items, id: \.selectedVariantId) { item in
                CartItemRow(
                    item: item,
                    decreaseQuantity: {
                        viewModel.decreaseQuantity($0)
                    }, increaseQuantity: {
                        viewModel.increaseQuantity($0)
                    }
                )
            }
            .onDelete { indexSet in
                indexSet.map { viewModel.items[$0] }.forEach { viewModel.remove($0) }
            }

            totalSection
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }

    var totalSection: some View {
        VStack(spacing: 16) {
            Divider()

            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text(viewModel.totalPrice, format: .currency(code: viewModel.currency))
                    .font(.headline)
            }
            .padding(.horizontal)

            Button {
                viewModel.checkout()
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
    CartView(
        items: [CartItem(
            product: Product.mockProducts.first!,
            selectedSize: .m,
            selectedVariantId: "TRS-001-BEI",
            quantity: 2
        )]
    )
}
