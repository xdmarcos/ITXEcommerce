//
//  AddToCartButtonView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 1/4/26.
//

import SwiftUI

struct AddToCartButtonView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var canAdd: Bool
    @State private var justAdded: Bool = false
    private var onTap: () -> Void = { }

    init(canAdd: Bool = false, onTap: @escaping () -> Void = { }) {
        self.canAdd = canAdd
        self.onTap = onTap
    }

    var body: some View {
        VStack(spacing: 8) {
            Button {
                onTap()
                withAnimation(reduceMotion ? .none : .spring(duration: 0.3)) { justAdded = true }
            } label: {
                Label(
                    justAdded ? "Added!" : (canAdd ? "Add to Cart" : "Out of Stock"),
                    systemImage: justAdded ? "checkmark" : "cart.badge.plus"
                )
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 52)
                .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canAdd)

            if !canAdd {
                Text("You've added all available stock to your cart.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .task(id: justAdded) {
            guard justAdded else { return }
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(reduceMotion ? .none : .spring(duration: 0.3)) { justAdded = false }
        }
        .animation(reduceMotion ? .none : .easeInOut, value: canAdd)
    }
}

#Preview {
    AddToCartButtonView()
}
