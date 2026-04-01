//
//  ProductCategory+Color.swift
//  ITXEcommerce
//

import SwiftUI

extension ProductCategory {
    var color: Color {
        switch self {
        case .miscellaneous:      .red
        case .beauty:             .pink
        case .fragrances:         .purple
        case .furniture:          .brown
        case .groceries:          .green
        case .homeDecoration:     .orange
        case .kitchenAccessories: .red
        case .laptops:            .blue
        case .mensShirts:         .indigo
        case .mensShoes:          Color(hue: 0.08, saturation: 0.6, brightness: 0.55)
        case .mensWatches:        .gray
        case .mobileAccessories:  .cyan
        case .motorcycle:         Color(hue: 0.02, saturation: 0.8, brightness: 0.7)
        case .skinCare:           .mint
        case .smartphones:        Color(hue: 0.58, saturation: 0.7, brightness: 0.8)
        case .sportsAccessories:  Color(hue: 0.09, saturation: 0.9, brightness: 0.85)
        case .sunglasses:         Color(hue: 0.14, saturation: 0.8, brightness: 0.85)
        case .tablets:            Color(hue: 0.55, saturation: 0.6, brightness: 0.75)
        case .tops:               .teal
        case .vehicle:            Color(hue: 0.01, saturation: 0.75, brightness: 0.65)
        case .womensBags:         Color(hue: 0.92, saturation: 0.6, brightness: 0.8)
        case .womensDresses:      Color(hue: 0.88, saturation: 0.5, brightness: 0.85)
        case .womensJewellery:    Color(hue: 0.13, saturation: 0.7, brightness: 0.75)
        case .womensShoes:        Color(hue: 0.95, saturation: 0.55, brightness: 0.75)
        case .womensWatches:      Color(hue: 0.78, saturation: 0.5, brightness: 0.7)
        }
    }
}
