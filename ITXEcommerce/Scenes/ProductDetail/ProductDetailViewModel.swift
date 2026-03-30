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
    }

    func addToCart() {
        guard let size = selectedSize, let variant = activeVariant else { return }
        // TODO
    }
}
