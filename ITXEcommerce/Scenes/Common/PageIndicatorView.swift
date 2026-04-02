//
//  PageIndicatorView.swift
//  ITXEcommerce
//

import SwiftUI

struct PageIndicatorView: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == current ? Color.primary : Color.primary.opacity(0.3))
                    .frame(width: index == current ? 16 : 6, height: 6)
                    .animation(.spring(duration: 0.3), value: current)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: .capsule)
    }
}
