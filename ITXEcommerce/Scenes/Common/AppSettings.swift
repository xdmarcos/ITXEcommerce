//
//  AppSettings.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 2/4/26.
//

import Foundation
import SwiftUI

enum AppColorScheme: String, CaseIterable {
    case light, dark, system

    var title: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        case .system: "Auto"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        case .system: nil
        }
    }
}

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case galician = "gl"
    case spanish = "es"

    var title: String {
        switch self {
        case .english: "English"
        case .galician: "Galician"
        case .spanish: "Spanish"
        }
    }

    var locale: Locale { Locale(identifier: rawValue) }
}
