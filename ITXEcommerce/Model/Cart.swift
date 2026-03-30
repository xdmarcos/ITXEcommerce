//
//  Cart.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation
import SwiftData

@Model
final class Cart {
    #Unique<Cart>([\.userID])

    var userID: UUID

    @Relationship(deleteRule: .cascade)
    var items: [CartItem]

    init(userID: UUID, items: [CartItem]) {
        self.userID = userID
        self.items = items
    }
}
