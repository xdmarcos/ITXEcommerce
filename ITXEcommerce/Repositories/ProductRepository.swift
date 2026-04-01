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

    func fetchPage(skip: Int, limit: Int) async throws -> (products: [Product], total: Int) {
        do {
            let response = try await apiClient.asyncRequest(
                endpoint: DummyJsonEndpointProvider.getProducts(pagination: .init(limit: limit, skip: skip)),
                responseModel: ProductsDTO.self
            )
            let batch = response.asProducts()
            let pageProducts = try upsert(batch, returnAll: false)
            return (pageProducts, response.total)
        } catch {
            let mocks = Product.mockProducts
            let page = Array(mocks.dropFirst(skip).prefix(limit))
            return (page, mocks.count)
        }
    }

    func fetchAll() async throws -> [Product] {
        do {
            let response = try await apiClient.asyncRequest(
                endpoint: DummyJsonEndpointProvider.getProducts(pagination: .init(limit: 0, skip: nil)),
                responseModel: ProductsDTO.self
            )
            return try upsert(response.asProducts())
        } catch {
            return Product.mockProducts
        }
    }

    @discardableResult
    private func upsert(_ products: [Product], returnAll: Bool = true) throws -> [Product] {
        let productIds = products.map(\.productId)
        let existingMap = try modelContext
            .fetch(FetchDescriptor<Product>(predicate: #Predicate { productIds.contains($0.productId) }))
            .reduce(into: [String: Product]()) { $0[$1.productId] = $1 }

        var batchResult: [Product] = []
        for product in products {
            if let existing = existingMap[product.productId] {
                existing.title = product.title
                existing.brand = product.brand
                existing.productDescription = product.productDescription
                existing.category = product.category
                existing.price = product.price
                existing.discountPercentage = product.discountPercentage
                existing.rating = product.rating
                existing.stock = product.stock
                existing.tags = product.tags
                existing.thumbnail = product.thumbnail
                existing.images = product.images
                batchResult.append(existing)
            } else {
                modelContext.insert(product)
                batchResult.append(product)
            }
        }
        try modelContext.save()

        if returnAll {
            return try modelContext.fetch(FetchDescriptor<Product>())
        }
        return batchResult
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
