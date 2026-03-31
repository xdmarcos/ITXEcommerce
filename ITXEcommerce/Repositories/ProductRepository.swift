//
//  ProductRepository.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation
import SwiftData

@MainActor
final class ProductRepository: ProductRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() async throws -> [Product] {
//        try modelContext.fetch(FetchDescriptor<Product>())
        Product.mockProducts
    }

    func fetch(category: ProductCategory?) async throws -> [Product] {
        guard let category else { return try await fetchAll() }
        let descriptor = FetchDescriptor<Product>(
            predicate: #Predicate { $0.category == category }
        )
        return try modelContext.fetch(descriptor)
    }
}
