//
//  SettingsViewModel.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

@Observable
final class SettingsViewModel {
    private enum Keys {
        static let colorScheme = "appColorScheme"
        static let language = "appLanguage"
    }
    private let repository: any ProductRepositoryProtocol
    private let defaults: UserDefaults
    private(set) var cacheCleared = false

    enum SettingsError: LocalizedError {
        case unknown(Error? = nil)
        case clearCache(Error? = nil)

        var errorDescription: LocalizedStringResource? {
            switch self {
            case .unknown: return "Unknown Error"
            case .clearCache: return "Failed to clear cache"
            }
        }

        var recoverySuggestion: LocalizedStringResource? {
            switch self {
            case .unknown(let error): return LocalizedStringResource(stringLiteral: error?.localizedDescription ?? "")
            case .clearCache: return "An unexpected error occurred. Please try again later."
            }
        }
    }

    var settingsError: Error?

    var colorScheme: AppColorScheme {
        didSet { defaults.set(colorScheme.rawValue, forKey: Keys.colorScheme) }
    }
    var language: AppLanguage {
        didSet { defaults.set(language.rawValue, forKey: Keys.language) }
    }
    var showClearCacheConfirmation = false

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

    func clearCacheError() {
        settingsError = nil
    }

    @discardableResult
    func clearCache() -> Task<Void, Never> {
        Task { @MainActor in
            do {
                try repository.clearCache()
                cacheCleared = true
                clearCacheError()
            } catch {
                settingsError = SettingsError.clearCache(error)
            }
        }
    }
}
