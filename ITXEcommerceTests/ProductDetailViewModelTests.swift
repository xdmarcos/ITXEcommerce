//
//  ProductDetailViewModelTests.swift
//  ITXEcommerceTests
//

@testable import ITXEcommerce
import Foundation
import Testing

@Suite("ProductDetailViewModel")
@MainActor
struct ProductDetailViewModelTests {

    // MARK: Initial state

    @Test func initialCurrentImageIndexIsZero() {
        let vm = ProductDetailViewModel(product: makeProduct())
        #expect(vm.currentImageIndex == 0)
    }

    @Test func productIsStoredOnInit() {
        let product = makeProduct(id: "unique-id")
        let vm = ProductDetailViewModel(product: product)
        #expect(vm.product.productId == "unique-id")
    }

    @Test func productSkuIsAccessible() {
        let product = makeProduct(id: "P1")
        let vm = ProductDetailViewModel(product: product)
        #expect(vm.product.sku == "SKU-1234")
    }

    @Test func productTitleIsAccessible() {
        let product = makeProduct(id: "P1")
        let vm = ProductDetailViewModel(product: product)
        #expect(vm.product.title == "Test Product")
    }

    @Test func productImagesAreAccessible() {
        let product = makeProduct(id: "P1")
        let vm = ProductDetailViewModel(product: product)
        #expect(vm.product.images.count == 2)
    }

    @Test func productThumbnailIsAccessible() {
        let product = makeProduct(id: "P1")
        let vm = ProductDetailViewModel(product: product)
        #expect(!vm.product.thumbnail.isEmpty)
    }

    @Test func productRatingIsAccessible() {
        let product = makeProduct(id: "P1")
        let vm = ProductDetailViewModel(product: product)
        #expect(vm.product.rating == 4.5)
    }

    @Test func productStockIsAccessible() {
        let product = makeProduct(id: "P1")
        let vm = ProductDetailViewModel(product: product)
        #expect(vm.product.stock == 10)
    }

    @Test func productDiscountPercentageIsAccessible() {
        let product = makeProduct(id: "P1")
        let vm = ProductDetailViewModel(product: product)
        #expect(vm.product.discountPercentage == 5.0)
    }

    @Test func productTagsAreAccessible() {
        let product = makeProduct(id: "P1")
        let vm = ProductDetailViewModel(product: product)
        #expect(vm.product.tags == ["test", "mock"])
    }

}

// MARK: - Helpers

private extension ProductDetailViewModelTests {
    func makeProduct(id: String = "P1") -> Product {
        Product(
            productId: id,
            sku: "SKU-1234",
            title: "Test Product",
            brand: "Test Brand",
            productDescription: "Test Description",
            category: .beauty,
            price: 29.99,
            discountPercentage: 5.0,
            rating: 4.5,
            stock: 10,
            tags: ["test", "mock"],
            thumbnail: "https://example.com/thumbnail.webp",
            images: [
                "https://example.com/image1.webp",
                "https://example.com/image2.webp"
            ]
        )
    }
}
