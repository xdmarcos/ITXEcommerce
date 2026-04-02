//
//  MockRemoteDataSource.swift
//  ITXEcommerceTests
//
//  Created by xdmGzDev on 2/4/26.
//

import Foundation
@testable import ITXEcommerce

struct RemoteStubError: Error, Equatable {}

@MainActor
final class MockRemoteDataSource: RemoteDataSourceProtocol {
    var pageResult: Result<ProductsDTO, Error>
    var allResult: Result<ProductsDTO, Error>
    var productResult: Result<ProductDTO, Error>

    private(set) var lastPageSkip: Int?
    private(set) var lastPageLimit: Int?

    init(
        pageResult: ProductsDTO = ProductsDTO(products: [], total: 0, skip: 0, limit: 0),
        allResult: ProductsDTO = ProductsDTO(products: [], total: 0, skip: 0, limit: 0),
        productResult: ProductDTO? = nil,
        error: Error? = nil
    ) {
        self.pageResult = error.map { .failure($0) } ?? .success(pageResult)
        self.allResult = error.map { .failure($0) } ?? .success(allResult)
        self.productResult = error.map { .failure($0) } ?? productResult.map { .success($0) } ?? .failure(RemoteStubError())
    }

    func fetchPage(skip: Int, limit: Int) async throws -> ProductsDTO {
        lastPageSkip = skip
        lastPageLimit = limit
        return try pageResult.get()
    }

    func fetchAll() async throws -> ProductsDTO { try allResult.get() }
    func fetchProduct(id: String) async throws -> ProductDTO { try productResult.get() }
}
