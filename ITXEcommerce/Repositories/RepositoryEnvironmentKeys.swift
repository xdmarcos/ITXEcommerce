//
//  RepositoryEnvironmentKeys.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var productRepository: any ProductRepositoryProtocol = MockProductRepository()
}
