//
//  ProductRepository.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import CoreNetwork
import Foundation
import SwiftData

@MainActor
final class ProductRepository: ProductRepositoryProtocol {
    private let modelContext: ModelContext
    private let apiClient: ApiClientProtocol = ApiClient()

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() async throws -> [Product] {
//        try modelContext.fetch(FetchDescriptor<Product>())
//        Product.mockProducts
        do {
            let response = try await apiClient.asyncRequest(
                endpoint: DummyJsonEndpointProvider.getProducts(pagination: .init(limit: 0, skip: nil)),
                responseModel: ProductsDTO.self
            )
            debugPrint("response: \(response)")
            return response.asProducts()
        } catch {
            return Product.mockProducts
        }
    }

    func fetch(category: ProductCategory?) async throws -> [Product] {
        guard let category else { return try await fetchAll() }
        let descriptor = FetchDescriptor<Product>(
            predicate: #Predicate { $0.category == category }
        )
        return try modelContext.fetch(descriptor)
    }
}

extension ProductsDTO {
    func asProducts() -> [Product] {
        products.map { dto in
            Product(
                productId: dto.sku,
                title: dto.title,
                brand: dto.brand ?? "Generic",
                productDescription: dto.description,
                category: ProductCategory(rawValue: dto.category) ?? .tops,
                price: Decimal(dto.price),
                discountPercentage: dto.discountPercentage,
                rating: dto.rating,
                stock: dto.stock,
                tags: dto.tags,
                thumbnail: dto.thumbnail,
                images: dto.images
            )
        }
    }
}
