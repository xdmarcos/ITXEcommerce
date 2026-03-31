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

    @Test func initialSelectedVariantIsNil() {
        let vm = ProductDetailViewModel(product: makeProduct())
        #expect(vm.selectedVariant == nil)
    }

    @Test func initialSelectedSizeIsNil() {
        let vm = ProductDetailViewModel(product: makeProduct())
        #expect(vm.selectedSize == nil)
    }

    @Test func initialShowCartDetailIsFalse() {
        let vm = ProductDetailViewModel(product: makeProduct())
        #expect(vm.showCartDetail == false)
    }

    @Test func initialCurrentImageIndexIsZero() {
        let vm = ProductDetailViewModel(product: makeProduct())
        #expect(vm.currentImageIndex == 0)
    }

    @Test func productIsStoredOnInit() {
        let product = makeProduct(id: "unique-id")
        let vm = ProductDetailViewModel(product: product)
        #expect(vm.product.productId == "unique-id")
    }

    // MARK: Active variant

    @Test func activeVariantDefaultsToFirstVariantWhenNoneSelected() {
        let variant1 = makeVariant(id: "V1")
        let variant2 = makeVariant(id: "V2")
        let product = makeProduct(variants: [variant1, variant2])
        let vm = ProductDetailViewModel(product: product)

        #expect(vm.activeVariant == variant1)
    }

    @Test func activeVariantIsNilWhenProductHasNoVariants() {
        let product = makeProduct(variants: [])
        let vm = ProductDetailViewModel(product: product)
        #expect(vm.activeVariant == nil)
    }

    @Test func activeVariantReturnsSelectedVariant() {
        let variant1 = makeVariant(id: "V1")
        let variant2 = makeVariant(id: "V2")
        let product = makeProduct(variants: [variant1, variant2])
        let vm = ProductDetailViewModel(product: product)

        vm.selectVariant(variant2)

        #expect(vm.activeVariant == variant2)
    }

    // MARK: Variant selection

    @Test func selectVariantUpdatesSelectedVariant() {
        let variant = makeVariant(id: "V1")
        let product = makeProduct(variants: [variant])
        let vm = ProductDetailViewModel(product: product)

        vm.selectVariant(variant)

        #expect(vm.selectedVariant == variant)
    }

    @Test func selectVariantClearsPreviouslySelectedSize() {
        let variant1 = makeVariant(id: "V1", sizes: [.m, .l])
        let variant2 = makeVariant(id: "V2", sizes: [.s])
        let product = makeProduct(variants: [variant1, variant2])
        let vm = ProductDetailViewModel(product: product)

        vm.selectSize(.m)
        vm.selectVariant(variant2)

        #expect(vm.selectedSize == nil)
    }

    // MARK: Size selection

    @Test func selectSizeUpdatesSelectedSize() {
        let vm = ProductDetailViewModel(product: makeProduct())

        vm.selectSize(.l)

        #expect(vm.selectedSize == .l)
    }

    @Test func selectSizeCanBeChangedToAnotherSize() {
        let vm = ProductDetailViewModel(product: makeProduct())

        vm.selectSize(.s)
        vm.selectSize(.m)

        #expect(vm.selectedSize == .m)
    }

    // MARK: Size availability

    @Test func isSizeAvailableReturnsTrueForSizeInActiveVariant() {
        let variant = makeVariant(id: "V1", sizes: [.s, .m, .l])
        let vm = ProductDetailViewModel(product: makeProduct(variants: [variant]))

        #expect(vm.isSizeAvailable(.s) == true)
        #expect(vm.isSizeAvailable(.m) == true)
        #expect(vm.isSizeAvailable(.l) == true)
    }

    @Test func isSizeAvailableReturnsFalseForSizeNotInActiveVariant() {
        let variant = makeVariant(id: "V1", sizes: [.s, .m])
        let vm = ProductDetailViewModel(product: makeProduct(variants: [variant]))

        #expect(vm.isSizeAvailable(.xl) == false)
        #expect(vm.isSizeAvailable(.xxl) == false)
    }

    @Test func isSizeAvailableReturnsFalseWhenProductHasNoVariants() {
        let vm = ProductDetailViewModel(product: makeProduct(variants: []))
        #expect(vm.isSizeAvailable(.m) == false)
    }

    @Test func isSizeAvailableChecksSelectedVariantNotDefaultVariant() {
        let variant1 = makeVariant(id: "V1", sizes: [.s, .m])
        let variant2 = makeVariant(id: "V2", sizes: [.xl, .xxl])
        let product = makeProduct(variants: [variant1, variant2])
        let vm = ProductDetailViewModel(product: product)

        vm.selectVariant(variant2)

        #expect(vm.isSizeAvailable(.xl) == true)
        #expect(vm.isSizeAvailable(.m) == false)
    }

    // MARK: Cart button

    @Test func cartButtonOnTapSetsShowCartDetail() {
        let vm = ProductDetailViewModel(product: makeProduct())

        vm.cartButtonOnTap()

        #expect(vm.showCartDetail == true)
    }
}

// MARK: - Helpers

fileprivate func makeVariant(
    id: String = "V1",
    colorName: String = "Black",
    colorHex: String = "#000000",
    sizes: [ProductSize] = [.s, .m, .l]
) -> ProductVariant {
    ProductVariant(id: id, colorName: colorName, colorHex: colorHex, imageURLs: [], availableSizes: sizes)
}

fileprivate func makeProduct(
    id: String = "P1",
    variants: [ProductVariant] = [
        makeVariant(id: "V1", sizes: [.s, .m, .l]),
        makeVariant(id: "V2", colorName: "White", colorHex: "#FFFFFF", sizes: [.m, .xl])
    ]
) -> Product {
    Product(
        productId: id,
        name: "Test Product",
        brand: "Test Brand",
        productDescription: "Test Description",
        category: .shirt,
        price: 29.99,
        variants: variants
    )
}
