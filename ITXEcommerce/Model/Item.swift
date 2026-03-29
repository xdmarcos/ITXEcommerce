//
//  Item.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 27/3/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
