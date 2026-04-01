//
//  ProductUpsertActor.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 1/4/26.
//

import Foundation
import SwiftData

struct ProductSnapshot: Sendable {
    let productId: String
    let title: String
    let brand: String
    let productDescription: String
    let category: ProductCategory
    let price: Decimal
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let tags: [String]
    let thumbnail: String
    let images: [String]
}

@ModelActor
actor ProductUpsertActor {
    func upsert(_ snapshots: [ProductSnapshot]) throws {
        let ids = snapshots.map(\.productId)
        let existingMap = try modelContext
            .fetch(FetchDescriptor<Product>(predicate: #Predicate { ids.contains($0.productId) }))
            .reduce(into: [String: Product]()) { $0[$1.productId] = $1 }

        for snapshot in snapshots {
            if let existing = existingMap[snapshot.productId] {
                existing.title = snapshot.title
                existing.brand = snapshot.brand
                existing.productDescription = snapshot.productDescription
                existing.category = snapshot.category
                existing.price = snapshot.price
                existing.discountPercentage = snapshot.discountPercentage
                existing.rating = snapshot.rating
                existing.stock = snapshot.stock
                existing.tags = snapshot.tags
                existing.thumbnail = snapshot.thumbnail
                existing.images = snapshot.images
            } else {
                modelContext.insert(Product(
                    productId: snapshot.productId,
                    title: snapshot.title,
                    brand: snapshot.brand,
                    productDescription: snapshot.productDescription,
                    category: snapshot.category,
                    price: snapshot.price,
                    discountPercentage: snapshot.discountPercentage,
                    rating: snapshot.rating,
                    stock: snapshot.stock,
                    tags: snapshot.tags,
                    thumbnail: snapshot.thumbnail,
                    images: snapshot.images
                ))
            }
        }
        try modelContext.save()
    }
}
