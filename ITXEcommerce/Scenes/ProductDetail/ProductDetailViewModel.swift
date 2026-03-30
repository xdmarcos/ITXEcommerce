//
//  ProductDetailViewModel.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

@Observable
final class ProductDetailViewModel {
    let product: Product

    var showCartDetail = false
    var cartItemCount = 0

    var selectedVariant: ProductVariant?
    var selectedSize: ProductSize?
    var currentImageIndex: Int = 0
    var activeVariant: ProductVariant? {
        selectedVariant ?? product.variants.first
    }

    init(product: Product) {
        self.product = product
    }

    func selectVariant(_ variant: ProductVariant) {
        selectedVariant = variant
        selectedSize = nil
    }

    func selectSize(_ size: ProductSize) {
        selectedSize = size
    }

    func addToCart() {
        guard let size = selectedSize, let variant = activeVariant else { return }
        cartItemCount += 1
        debugPrint(size, variant)
    }

    func isSizeAvailable(_ size: ProductSize) -> Bool {
        activeVariant?.availableSizes.contains(size) ?? false
    }

    func cartButtonOnTap() {
        showCartDetail = true
    }
}
