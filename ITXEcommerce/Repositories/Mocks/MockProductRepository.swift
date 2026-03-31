//
//  MockProductRepository.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

final class MockProductRepository: ProductRepositoryProtocol {
    private let products: [Product]

    init(products: [Product] = []) {
        self.products = products
    }

    func fetchAll() throws -> [Product] {
        products
    }

    func fetch(category: ProductCategory?) throws -> [Product] {
        guard let category else { return products }
        return products.filter { $0.category == category }
    }
}
