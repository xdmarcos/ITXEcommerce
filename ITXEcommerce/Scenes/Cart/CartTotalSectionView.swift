//
//  CartTotalSectionView.swift
//  ITXEcommerce
//

import SwiftUI

struct CartTotalSectionView: View {
    var cartViewModel: CartViewModel

    var body: some View {
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
