//
//  Product.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation
import SwiftData

enum ProductCategory: String, Codable, CaseIterable, Sendable, Equatable, Displayable {
    case miscellaneous       = "miscellaneous"
    case beauty              = "beauty"
    case fragrances          = "fragrances"
    case furniture           = "furniture"
    case groceries           = "groceries"
    case homeDecoration      = "home-decoration"
    case kitchenAccessories  = "kitchen-accessories"
    case laptops             = "laptops"
    case mensShirts          = "mens-shirts"
    case mensShoes           = "mens-shoes"
    case mensWatches         = "mens-watches"
    case mobileAccessories   = "mobile-accessories"
    case motorcycle          = "motorcycle"
    case skinCare            = "skin-care"
    case smartphones         = "smartphones"
    case sportsAccessories   = "sports-accessories"
    case sunglasses          = "sunglasses"
    case tablets             = "tablets"
    case tops                = "tops"
    case vehicle             = "vehicle"
    case womensBags          = "womens-bags"
    case womensDresses       = "womens-dresses"
    case womensJewellery     = "womens-jewellery"
    case womensShoes         = "womens-shoes"
    case womensWatches       = "womens-watches"

    var displayName: String {
        switch self {
        case .miscellaneous:      "Miscellaneous"
        case .beauty:             "Beauty"
        case .fragrances:         "Fragrances"
        case .furniture:          "Furniture"
        case .groceries:          "Groceries"
        case .homeDecoration:     "Home Decoration"
        case .kitchenAccessories: "Kitchen Accessories"
        case .laptops:            "Laptops"
        case .mensShirts:         "Men's Shirts"
        case .mensShoes:          "Men's Shoes"
        case .mensWatches:        "Men's Watches"
        case .mobileAccessories:  "Mobile Accessories"
        case .motorcycle:         "Motorcycle"
        case .skinCare:           "Skin Care"
        case .smartphones:        "Smartphones"
        case .sportsAccessories:  "Sports Accessories"
        case .sunglasses:         "Sunglasses"
        case .tablets:            "Tablets"
        case .tops:               "Tops"
        case .vehicle:            "Vehicle"
        case .womensBags:         "Women's Bags"
        case .womensDresses:      "Women's Dresses"
        case .womensJewellery:    "Women's Jewellery"
        case .womensShoes:        "Women's Shoes"
        case .womensWatches:      "Women's Watches"
        }
    }
}

@Model
final class Product {
    #Unique<Product>([\.productId])

    var productId: String
    var title: String
    var brand: String
    var productDescription: String
    var category: ProductCategory
    var price: Decimal
    var discountPercentage: Double
    var rating: Double
    var stock: Int
    var tags: [String]
    var thumbnail: String
    var images: [String]

    init(
        productId: String,
        title: String,
        brand: String,
        productDescription: String,
        category: ProductCategory,
        price: Decimal,
        discountPercentage: Double = 0,
        rating: Double = 0,
        stock: Int = 0,
        tags: [String] = [],
        thumbnail: String = "",
        images: [String] = []
    ) {
        self.productId = productId
        self.title = title
        self.brand = brand
        self.productDescription = productDescription
        self.category = category
        self.price = price
        self.discountPercentage = discountPercentage
        self.rating = rating
        self.stock = stock
        self.tags = tags
        self.thumbnail = thumbnail
        self.images = images
    }
}
