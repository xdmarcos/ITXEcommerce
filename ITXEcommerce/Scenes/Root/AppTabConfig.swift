//
//  AppTabConfig.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import Foundation

enum AppTabConfig {
    case catalog
    case quickStart
    case settings

    var title: LocalizedStringResource {
        switch self {
        case .catalog: "Catalog"
        case .quickStart: "Quick Start"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .catalog: "square.grid.3x3.fill"
        case .quickStart: "info.bubble.fill"
        case .settings: "gearshape"
        }
    }
}
