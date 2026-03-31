//
//  ITXEcommerceApp.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 27/3/26.
//

import SwiftData
import SwiftUI

@main
struct ITXEcommerceApp: App {
    private let container: ModelContainer
    private let cartViewModel: CartViewModel
    private let productRepository: any ProductRepositoryProtocol

    init() {
        do {
            let container = try ModelContainer(for: Product.self, CartItem.self)
            self.container = container
            self.cartViewModel = CartViewModel(repository: CartRepository(modelContext: container.mainContext))
            self.productRepository = ProductRepository(modelContext: container.mainContext)
        } catch {
            fatalError("ModelContainer init failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(cartViewModel)
                .environment(\.productRepository, productRepository)
        }
        .modelContainer(container)
    }
}
