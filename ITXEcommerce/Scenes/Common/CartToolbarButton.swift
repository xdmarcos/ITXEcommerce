//
//  CartToolbarButton.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct CartToolbarButton: View {
    private var itemCount = 0
    private var onTap: () -> Void = { }

    init(itemCount: Int = 0, onTap: @escaping () -> Void = { }) {
        self.itemCount = itemCount
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            cartIcon
        }
        .accessibilityLabel(Text("Cart, ^[\(itemCount) item](inflect: true)"))
    }

    private var cartIcon: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "cart")
                .padding(.top, itemCount > 0 ? 8 : 0)
                .padding(.trailing, itemCount > 0 ? 10 : 0)

            if itemCount > 0 {
                Text(itemCount < 100 ? "\(itemCount)" : "99+")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(.red, in: Capsule())
            }
        }
    }
}

// MARK: - Previews

#Preview {
    VStack(spacing: 30) {
        CartToolbarButton(itemCount: 0)
        CartToolbarButton(itemCount: 3)
    }
}
