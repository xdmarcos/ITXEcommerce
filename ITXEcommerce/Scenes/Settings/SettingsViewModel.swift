//
//  SettingsViewModel.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

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

@Observable
final class SettingsViewModel {
    private enum Keys {
        static let colorScheme = "appColorScheme"
        static let language = "appLanguage"
    }

    private let repository: any ProductRepositoryProtocol
    private let defaults: UserDefaults

    var colorScheme: AppColorScheme {
        didSet { defaults.set(colorScheme.rawValue, forKey: Keys.colorScheme) }
    }
    var language: AppLanguage {
        didSet { defaults.set(language.rawValue, forKey: Keys.language) }
    }
    var showClearCacheConfirmation = false
    private(set) var cacheCleared = false
    private(set) var clearCacheError: Error?

    init(repository: any ProductRepositoryProtocol, defaults: UserDefaults = .standard) {
        self.repository = repository
        self.defaults = defaults
        colorScheme = AppColorScheme(
            rawValue: defaults.string(forKey: Keys.colorScheme) ?? ""
        ) ?? .system
        language = AppLanguage(
            rawValue: defaults.string(forKey: Keys.language) ?? ""
        ) ?? .english
    }

    func clearCacheButtonOnTap() {
        showClearCacheConfirmation = true
    }

    func cacheClearedDismissed() {
        cacheCleared = false
    }

    func clearCacheErrorDismissed() {
        clearCacheError = nil
    }

    @discardableResult
    func clearCache() -> Task<Void, Never> {
        Task { @MainActor in
            do {
                try self.repository.clearCache()
                self.cacheCleared = true
            } catch {
                self.clearCacheError = error
            }
        }
    }
}
