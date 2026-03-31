//
//  ProductRepositoryProtocol.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

protocol ProductRepositoryProtocol {
    func fetchAll() throws -> [Product]
    func fetch(category: ProductCategory?) throws -> [Product]
}
