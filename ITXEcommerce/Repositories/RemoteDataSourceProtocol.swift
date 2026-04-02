//
//  RemoteDataSourceProtocol.swift
//  ITXEcommerce
//

import Foundation

protocol RemoteDataSourceProtocol: Sendable {
    func fetchPage(skip: Int, limit: Int) async throws -> ProductsDTO
    func fetchAll() async throws -> ProductsDTO
    func fetchProduct(id: String) async throws -> ProductDTO
}
