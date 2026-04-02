//
//  ITXEcommerceApp.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 27/3/26.
//

import CoreNetwork
import SwiftData
import SwiftUI

@main
struct ITXEcommerceApp: App {
    private let container: ModelContainer
    private let cartViewModel: CartViewModel
    private let productRepository: any ProductRepositoryProtocol
    private let settingsViewModel: SettingsViewModel

    init() {
        CachedAsyncImageConfiguration.setMemoryCostLimit(50 * 1024 * 1024)

        do {
            let container = try ModelContainer(
                for: Product.self, CartItem.self,
                migrationPlan: ITXEcommerceMigrationPlan.self
            )
            self.container = container
            let productRepository = ProductRepository(
                modelContainer: container,
                remoteDataSource: DummyJsonRemoteDataSource(apiClient: ApiClient())
            )
            self.productRepository = productRepository
            let cartRepository = CartRepository(modelContext: container.mainContext)
            self.cartViewModel = CartViewModel(repository: cartRepository)
            self.settingsViewModel = SettingsViewModel(
                cacheManager: ClearAllDataService(
                    productRepository: productRepository,
                    cartRepository: cartRepository
                )
            )
        } catch {
            fatalError("ModelContainer init failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(cartViewModel)
                .environment(settingsViewModel)
                .environment(\.productRepository, productRepository)
        }
        .modelContainer(container)
    }
}
