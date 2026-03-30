//
//  RootViewModel.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

enum AppTab {
    case catalog
    case favorites
    case settings

    var title: LocalizedStringResource {
        switch self {
        case .catalog: "Catalog"
        case .favorites: "Favorites"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .catalog: "square.grid.3x3.fill"
        case .favorites: "star.fill"
        case .settings: "gearshape"
        }
    }
}
