//
//  Product.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation
import SwiftData

enum ProductCategory: String, Codable, CaseIterable, Sendable, Equatable {
    case trousers
    case denim
    case hoodies
    case jacket
    case shirt
    case shoes
    case accessories

    var displayName: String {
        switch self {
        case .trousers: "Trousers"
        case .denim: "Denim"
        case .hoodies: "Hoodies"
        case .jacket: "Jacket"
        case .shirt: "Shirt"
        case .shoes: "Shoes"
        case .accessories: "Accessories"
        }
    }
}

enum ProductSize: String, Codable, CaseIterable, Sendable, Equatable {
    case xxs = "XXS"
    case xs = "XS"
    case s = "S"
    case m = "M"
    case l = "L"
    case xl = "XL"
    case xxl = "XXL"
}

struct ProductVariant: Codable, Sendable, Identifiable, Equatable {
    var id: String
    var colorName: String
    var colorHex: String
    var imageURLs: [String]
    var availableSizes: [ProductSize]
}

@Model
final class Product {
    #Unique<Product>([\.productId])

    var productId: String
    var name: String
    var brand: String
    var productDescription: String
    var category: ProductCategory
    var price: Decimal
    var currency: String
    var variants: [ProductVariant]

    init(
        productId: String,
        name: String,
        brand: String,
        productDescription: String,
        category: ProductCategory,
        price: Decimal,
        currency: String = "EUR",
        variants: [ProductVariant] = []
    ) {
        self.productId = productId
        self.name = name
        self.brand = brand
        self.productDescription = productDescription
        self.category = category
        self.price = price
        self.currency = currency
        self.variants = variants
    }
}
