//
//  ClearAllDataService.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 2/4/26.
//

import Foundation

struct ClearAllDataService: CacheManageable {
    private let productRepository: any CacheManageable
    private let cartRepository: any CartRepositoryProtocol

    init(productRepository: any CacheManageable, cartRepository: any CartRepositoryProtocol) {
        self.productRepository = productRepository
        self.cartRepository = cartRepository
    }

    func clearCache() throws {
        try cartRepository.clear()
        try productRepository.clearCache()
    }
}
