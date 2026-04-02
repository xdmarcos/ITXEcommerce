//
//  DummyJsonRemoteDataSource.swift
//  ITXEcommerce
//

import CoreNetwork
import Foundation

struct DummyJsonRemoteDataSource: RemoteDataSourceProtocol {
    private let apiClient: any ApiClientProtocol

    init(apiClient: any ApiClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchPage(skip: Int, limit: Int) async throws -> ProductsDTO {
        try await apiClient.asyncRequest(
            endpoint: DummyJsonEndpointProvider.getProducts(pagination: .init(limit: limit, skip: skip)),
            responseModel: ProductsDTO.self
        )
    }

    func fetchAll() async throws -> ProductsDTO {
        try await apiClient.asyncRequest(
            endpoint: DummyJsonEndpointProvider.getProducts(pagination: .init(limit: 0, skip: nil)),
            responseModel: ProductsDTO.self
        )
    }

    func fetchProduct(id: String) async throws -> ProductDTO {
        try await apiClient.asyncRequest(
            endpoint: DummyJsonEndpointProvider.getProductById(productId: id),
            responseModel: ProductDTO.self
        )
    }
}
