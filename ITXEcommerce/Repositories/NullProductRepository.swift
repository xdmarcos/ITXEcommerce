//
//  NullProductRepository.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 2/4/26.
//

import Foundation

final class NullProductRepository: ProductRepositoryProtocol {
    func fetchAll() async throws -> [Product] { [] }
    func fetch(category: ProductCategory?) async throws -> [Product] { [] }
    func fetchPage(skip: Int, limit: Int) async throws -> (products: [Product], total: Int) { ([], 0) }
    func fetchProduct(id: String) async throws -> Product? { nil }
    func clearCache() throws {}
}
