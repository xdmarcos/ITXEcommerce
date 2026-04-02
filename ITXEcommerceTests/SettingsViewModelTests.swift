//
//  SettingsViewModelTests.swift
//  ITXEcommerceTests
//

@testable import ITXEcommerce
import Foundation
import Testing
import SwiftUI

@Suite("SettingsViewModel")
@MainActor
struct SettingsViewModelTests {

    // MARK: Initial state

    @Test func defaultColorSchemeIsSystem() {
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: makeDefaults())
        #expect(vm.colorScheme == .system)
    }

    @Test func defaultLanguageIsEnglish() {
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: makeDefaults())
        #expect(vm.language == .english)
    }

    @Test func showClearCacheConfirmationIsFalseInitially() {
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: makeDefaults())
        #expect(vm.showClearCacheConfirmation == false)
    }

    @Test func cacheClearedIsFalseInitially() {
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: makeDefaults())
        #expect(vm.cacheCleared == false)
    }

    @Test func clearCacheErrorIsNilInitially() {
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: makeDefaults())
        #expect(vm.settingsError == nil)
    }

    // MARK: UserDefaults persistence

    @Test func changingColorSchemePersistsToUserDefaults() {
        let defaults = makeDefaults()
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: defaults)
        vm.colorScheme = .dark
        #expect(defaults.string(forKey: Keys.colorScheme) == "dark")
    }

    @Test func changingLanguagePersistsToUserDefaults() {
        let defaults = makeDefaults()
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: defaults)
        vm.language = .spanish
        #expect(defaults.string(forKey: Keys.language) == "es")
    }

    @Test func initRestoresColorSchemeFromUserDefaults() {
        let defaults = makeDefaults()
        defaults.set("light", forKey: Keys.colorScheme)
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: defaults)
        #expect(vm.colorScheme == .light)
    }

    @Test func initRestoresLanguageFromUserDefaults() {
        let defaults = makeDefaults()
        defaults.set("gl", forKey: Keys.language)
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: defaults)
        #expect(vm.language == .galician)
    }

    @Test func initFallsBackToSystemForUnknownColorScheme() {
        let defaults = makeDefaults()
        defaults.set("unknown", forKey: Keys.colorScheme)
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: defaults)
        #expect(vm.colorScheme == .system)
    }

    @Test func initFallsBackToEnglishForUnknownLanguage() {
        let defaults = makeDefaults()
        defaults.set("unknown", forKey: Keys.language)
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: defaults)
        #expect(vm.language == .english)
    }

    // MARK: Clear cache button

    @Test func clearCacheButtonOnTapSetsShowConfirmation() {
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: makeDefaults())
        vm.clearCacheButtonOnTap()
        #expect(vm.showClearCacheConfirmation == true)
    }

    // MARK: Clear cache — success

    @Test func clearCacheSetsCacheClearedOnSuccess() async {
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: makeDefaults())
        await vm.clearCache().value
        #expect(vm.cacheCleared == true)
    }

    @Test func clearCacheKeepsErrorNilOnSuccess() async {
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: makeDefaults())
        await vm.clearCache().value
        #expect(vm.settingsError == nil)
    }

    // MARK: Clear cache — failure

    @Test func clearCacheSetsErrorOnFailure() async {
        let vm = SettingsViewModel(cacheManager: FailingClearCacheRepository(), defaults: makeDefaults())
        await vm.clearCache().value
        #expect(vm.settingsError != nil)
    }

    @Test func clearCacheDoesNotSetCacheClearedOnFailure() async {
        let vm = SettingsViewModel(cacheManager: FailingClearCacheRepository(), defaults: makeDefaults())
        await vm.clearCache().value
        #expect(vm.cacheCleared == false)
    }

    // MARK: Dismiss handlers

    @Test func cacheClearedDismissedResetsCacheCleared() async {
        let vm = SettingsViewModel(cacheManager: MockCacheManager(), defaults: makeDefaults())
        await vm.clearCache().value
        vm.cacheClearedDismissed()
        #expect(vm.cacheCleared == false)
    }

    @Test func clearCacheErrorDismissedResetsError() async {
        let vm = SettingsViewModel(cacheManager: FailingClearCacheRepository(), defaults: makeDefaults())
        await vm.clearCache().value
        vm.clearCacheError()
        #expect(vm.settingsError == nil)
    }
}

// MARK: - AppColorScheme

@Suite("AppColorScheme")
struct AppColorSchemeTests {

    @Test func lightColorSchemeReturnsLight() {
        #expect(AppColorScheme.light.colorScheme == .light)
    }

    @Test func darkColorSchemeReturnsDark() {
        #expect(AppColorScheme.dark.colorScheme == .dark)
    }

    @Test func systemColorSchemeReturnsNil() {
        #expect(AppColorScheme.system.colorScheme == nil)
    }

    @Test func allCasesHaveNonEmptyTitles() {
        for scheme in AppColorScheme.allCases {
            #expect(!scheme.title.isEmpty)
        }
    }

    @Test func rawValuesMatchExpected() {
        #expect(AppColorScheme.light.rawValue == "light")
        #expect(AppColorScheme.dark.rawValue == "dark")
        #expect(AppColorScheme.system.rawValue == "system")
    }
}

// MARK: - AppLanguage

@Suite("AppLanguage")
struct AppLanguageTests {

    @Test func englishLocaleIdentifierIsEn() {
        #expect(AppLanguage.english.locale.identifier == "en")
    }

    @Test func spanishLocaleIdentifierIsEs() {
        #expect(AppLanguage.spanish.locale.identifier == "es")
    }

    @Test func galicianLocaleIdentifierIsGl() {
        #expect(AppLanguage.galician.locale.identifier == "gl")
    }

    @Test func allCasesHaveNonEmptyTitles() {
        for lang in AppLanguage.allCases {
            #expect(!lang.title.isEmpty)
        }
    }
}

// MARK: - Helpers

private extension SettingsViewModelTests {
    enum Keys {
        static let colorScheme = "appColorScheme"
        static let language = "appLanguage"
    }

    /// Returns a fresh, isolated UserDefaults suite so parallel tests never share state.
    func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: UUID().uuidString)!
    }
    
    final class FailingClearCacheRepository: CacheManageable {
        struct ClearCacheError: Error {}
        func clearCache() throws { throw ClearCacheError() }
    }
}
