//
//  ProductRepository.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation
import SwiftData

final class ProductRepository: ProductRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [Product] {
//        try modelContext.fetch(FetchDescriptor<Product>())
        Product.mockProducts
    }

    func fetch(category: ProductCategory?) throws -> [Product] {
        guard let category else { return try fetchAll() }
        let descriptor = FetchDescriptor<Product>(
            predicate: #Predicate { $0.category == category }
        )
        return try modelContext.fetch(descriptor)
    }
}
