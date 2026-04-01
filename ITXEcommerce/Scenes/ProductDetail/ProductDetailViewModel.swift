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

    var currentImageIndex = 0

    init(product: Product) {
        self.product = product
    }
}
