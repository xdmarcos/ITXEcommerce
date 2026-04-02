//
//  CartEmptyStateView.swift
//  ITXEcommerce
//

import SwiftUI

struct CartEmptyStateView: View {
    var body: some View {
        ContentUnavailableView(
            "Your Cart is Empty",
            systemImage: "cart",
            description: Text("Add products from the catalog to get started.")
        )
    }
}
