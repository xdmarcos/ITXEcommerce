//
//  MockProducts.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

@MainActor
extension Product {
    static let mockProducts: [Product] = [
        Product(
            productId: "SKU-001",
            title: "Essence Mascara Lash Princess",
            brand: "Essence",
            productDescription: "Popular mascara known for its volumizing and lengthening effects. Achieve dramatic lashes with this long-lasting and cruelty-free formula.",
            category: .beauty,
            price: 9.99,
            discountPercentage: 7.17,
            rating: 4.94,
            stock: 5,
            tags: ["beauty", "mascara"],
            thumbnail: "https://cdn.dummyjson.com/product-images/beauty/essence-mascara/thumbnail.webp",
            images: [
                "https://cdn.dummyjson.com/product-images/beauty/essence-mascara/1.webp",
                "https://cdn.dummyjson.com/product-images/beauty/essence-mascara/2.webp"
            ]
        ),
        Product(
            productId: "SKU-002",
            title: "Annibale Colombo Bed",
            brand: "Annibale Colombo",
            productDescription: "Luxurious and elegant bed frame with a timeless design, perfect for those who appreciate fine craftsmanship in their bedroom.",
            category: .furniture,
            price: 1899.99,
            discountPercentage: 0.00,
            rating: 4.14,
            stock: 12,
            tags: ["furniture", "bedroom"],
            thumbnail: "https://cdn.dummyjson.com/product-images/furniture/annibale-bed/thumbnail.webp",
            images: [
                "https://cdn.dummyjson.com/product-images/furniture/annibale-bed/1.webp",
                "https://cdn.dummyjson.com/product-images/furniture/annibale-bed/2.webp"
            ]
        ),
        Product(
            productId: "SKU-003",
            title: "iPhone 15 Pro",
            brand: "Apple",
            productDescription: "The latest iPhone with a titanium frame, A17 Pro chip, and a 48MP main camera system. Available in four stunning finishes.",
            category: .smartphones,
            price: 999.99,
            discountPercentage: 6.12,
            rating: 4.57,
            stock: 68,
            tags: ["smartphone", "apple", "ios"],
            thumbnail: "https://cdn.dummyjson.com/product-images/smartphones/iphone-15-pro/thumbnail.webp",
            images: [
                "https://cdn.dummyjson.com/product-images/smartphones/iphone-15-pro/1.webp",
                "https://cdn.dummyjson.com/product-images/smartphones/iphone-15-pro/2.webp",
                "https://cdn.dummyjson.com/product-images/smartphones/iphone-15-pro/3.webp"
            ]
        ),
        Product(
            productId: "SKU-004",
            title: "Calvin Klein CK One",
            brand: "Calvin Klein",
            productDescription: "A classic unisex fragrance with notes of bergamot, green tea, and musk. Fresh, clean, and unmistakably iconic.",
            category: .fragrances,
            price: 49.99,
            discountPercentage: 0.00,
            rating: 4.85,
            stock: 21,
            tags: ["fragrance", "unisex", "classic"],
            thumbnail: "https://cdn.dummyjson.com/product-images/fragrances/ck-one/thumbnail.webp",
            images: [
                "https://cdn.dummyjson.com/product-images/fragrances/ck-one/1.webp"
            ]
        ),
        Product(
            productId: "SKU-005",
            title: "MacBook Pro 14\"",
            brand: "Apple",
            productDescription: "Supercharged by the M3 Pro chip, the MacBook Pro delivers exceptional performance for professionals in a portable design.",
            category: .laptops,
            price: 1999.99,
            discountPercentage: 3.00,
            rating: 4.78,
            stock: 35,
            tags: ["laptop", "apple", "macos"],
            thumbnail: "https://cdn.dummyjson.com/product-images/laptops/macbook-pro-14/thumbnail.webp",
            images: [
                "https://cdn.dummyjson.com/product-images/laptops/macbook-pro-14/1.webp",
                "https://cdn.dummyjson.com/product-images/laptops/macbook-pro-14/2.webp"
            ]
        ),
        Product(
            productId: "SKU-006",
            title: "Hyaluronic Acid Serum",
            brand: "The Ordinary",
            productDescription: "A lightweight serum that delivers intense hydration with two molecular weights of hyaluronic acid, leaving skin plump and smooth.",
            category: .skinCare,
            price: 12.99,
            discountPercentage: 5.00,
            rating: 4.65,
            stock: 110,
            tags: ["skincare", "serum", "hydration"],
            thumbnail: "https://cdn.dummyjson.com/product-images/skin-care/hyaluronic-serum/thumbnail.webp",
            images: [
                "https://cdn.dummyjson.com/product-images/skin-care/hyaluronic-serum/1.webp"
            ]
        ),
        Product(
            productId: "SKU-007",
            title: "Slim Fit Oxford Shirt",
            brand: "Calvin Klein",
            productDescription: "A versatile slim-fit Oxford shirt crafted from breathable cotton. Perfect for both casual and formal occasions.",
            category: .mensShirts,
            price: 59.99,
            discountPercentage: 10.00,
            rating: 4.35,
            stock: 45,
            tags: ["shirt", "mens", "oxford"],
            thumbnail: "https://cdn.dummyjson.com/product-images/mens-shirts/oxford-shirt/thumbnail.webp",
            images: [
                "https://cdn.dummyjson.com/product-images/mens-shirts/oxford-shirt/1.webp",
                "https://cdn.dummyjson.com/product-images/mens-shirts/oxford-shirt/2.webp"
            ]
        ),
        Product(
            productId: "SKU-008",
            title: "Ray-Ban Wayfarer Classic",
            brand: "Ray-Ban",
            productDescription: "The iconic Wayfarer with UV400 lenses and a classic acetate frame. Timeless style for every occasion.",
            category: .sunglasses,
            price: 154.00,
            discountPercentage: 0.00,
            rating: 4.90,
            stock: 28,
            tags: ["sunglasses", "rayban", "classic"],
            thumbnail: "https://cdn.dummyjson.com/product-images/sunglasses/wayfarer/thumbnail.webp",
            images: [
                "https://cdn.dummyjson.com/product-images/sunglasses/wayfarer/1.webp"
            ]
        ),
        Product(
            productId: "SKU-009",
            title: "Floral Wrap Dress",
            brand: "Zara",
            productDescription: "A lightweight wrap dress featuring a vibrant floral print. Flattering V-neckline and adjustable waist tie.",
            category: .womensDresses,
            price: 49.95,
            discountPercentage: 15.00,
            rating: 4.45,
            stock: 60,
            tags: ["dress", "womens", "floral"],
            thumbnail: "https://cdn.dummyjson.com/product-images/womens-dresses/floral-wrap/thumbnail.webp",
            images: [
                "https://cdn.dummyjson.com/product-images/womens-dresses/floral-wrap/1.webp",
                "https://cdn.dummyjson.com/product-images/womens-dresses/floral-wrap/2.webp"
            ]
        ),
        Product(
            productId: "SKU-010",
            title: "Wireless Earbuds Pro",
            brand: "Samsung",
            productDescription: "Active noise cancellation, 30-hour battery life, and IPX5 water resistance for the ultimate wireless audio experience.",
            category: .mobileAccessories,
            price: 129.99,
            discountPercentage: 12.50,
            rating: 4.60,
            stock: 85,
            tags: ["earbuds", "wireless", "audio"],
            thumbnail: "https://cdn.dummyjson.com/product-images/mobile-accessories/earbuds-pro/thumbnail.webp",
            images: [
                "https://cdn.dummyjson.com/product-images/mobile-accessories/earbuds-pro/1.webp",
                "https://cdn.dummyjson.com/product-images/mobile-accessories/earbuds-pro/2.webp"
            ]
        )
    ]
}
