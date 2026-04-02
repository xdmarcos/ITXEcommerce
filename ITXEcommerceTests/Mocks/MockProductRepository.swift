//
//  MockProductRepository.swift
//  ITXEcommerceTests
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation
@testable import ITXEcommerce

final class MockProductRepository: ProductRepositoryProtocol {
    private let products: [Product]

    init(products: [Product] = []) {
        self.products = products
    }

    func fetchAll() async throws -> [Product] {
        products
    }

    func fetch(category: ProductCategory?) async throws -> [Product] {
        guard let category else { return products }
        return products.filter { $0.category == category }
    }

    func fetchPage(skip: Int, limit: Int) async throws -> (products: [Product], total: Int) {
        let page = Array(products.dropFirst(skip).prefix(limit))
        return (page, products.count)
    }

    func fetchProduct(id: String) async throws -> Product? {
        products.first(where: { $0.productId == id })
    }

    func clearCache() throws {}
}
