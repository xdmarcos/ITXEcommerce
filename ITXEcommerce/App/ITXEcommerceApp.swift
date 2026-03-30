//
//  ITXEcommerceApp.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 27/3/26.
//

import SwiftData
import SwiftUI

@main
struct ITXEcommerceApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Product.self, CartItem.self])
    }
}
