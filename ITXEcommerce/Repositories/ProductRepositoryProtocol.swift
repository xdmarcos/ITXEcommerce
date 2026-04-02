//
//  ProductRepositoryProtocol.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

protocol ProductRepositoryProtocol {
    func fetchAll() async throws -> [Product]
    func fetch(category: ProductCategory?) async throws -> [Product]
    func fetchPage(skip: Int, limit: Int) async throws -> (products: [Product], total: Int)
    func fetchProduct(id: String) async throws -> Product?
    func clearCache() throws
}
