//
//  ProductsDTO.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 31/3/26.
//

import Foundation

struct ProductsDTO: Codable {
    let products: [ProductDTO]
    let total, skip, limit: Int
}

struct ProductDTO: Codable {
    let id: Int
    let title, description, category: String
    let price, discountPercentage, rating: Double
    let stock: Int
    let tags: [String]
    let brand: String?
    let sku: String
    let weight: Int
    let dimensions: Dimensions
    let warrantyInformation, shippingInformation, availabilityStatus: String
    let reviews: [Review]
    let returnPolicy: String
    let minimumOrderQuantity: Int
    let meta: Meta
    let thumbnail: String
    let images: [String]
}

struct Dimensions: Codable {
    let width, height, depth: Double
}

struct Meta: Codable {
    let createdAt, updatedAt, barcode, qrCode: String
}

struct Review: Codable {
    let rating: Int
    let comment, date, reviewerName, reviewerEmail: String
}
