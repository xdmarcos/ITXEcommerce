//
//  SettingsViewModelTests.swift
//  ITXEcommerceTests
//

@testable import ITXEcommerce
import Foundation
import Testing

@Suite("SettingsViewModel")
@MainActor
struct SettingsViewModelTests {

    private enum Keys {
        static let colorScheme = "appColorScheme"
        static let language    = "appLanguage"
    }

    init() {
        UserDefaults.standard.removeObject(forKey: Keys.colorScheme)
        UserDefaults.standard.removeObject(forKey: Keys.language)
    }

    // MARK: Initial state

    @Test func defaultColorSchemeIsSystem() {
        let vm = SettingsViewModel(repository: MockProductRepository())
        #expect(vm.colorScheme == .system)
    }

    @Test func defaultLanguageIsEnglish() {
        let vm = SettingsViewModel(repository: MockProductRepository())
        #expect(vm.language == .english)
    }

    @Test func showClearCacheConfirmationIsFalseInitially() {
        let vm = SettingsViewModel(repository: MockProductRepository())
        #expect(vm.showClearCacheConfirmation == false)
    }

    @Test func cacheClearedIsFalseInitially() {
        let vm = SettingsViewModel(repository: MockProductRepository())
        #expect(vm.cacheCleared == false)
    }

    @Test func clearCacheErrorIsNilInitially() {
        let vm = SettingsViewModel(repository: MockProductRepository())
        #expect(vm.clearCacheError == nil)
    }

    // MARK: UserDefaults persistence

    @Test func changingColorSchemePersistsToUserDefaults() {
        let vm = SettingsViewModel(repository: MockProductRepository())
        vm.colorScheme = .dark
        #expect(UserDefaults.standard.string(forKey: Keys.colorScheme) == "dark")
    }

    @Test func changingLanguagePersistsToUserDefaults() {
        let vm = SettingsViewModel(repository: MockProductRepository())
        vm.language = .spanish
        #expect(UserDefaults.standard.string(forKey: Keys.language) == "es")
    }

    @Test func initRestoresColorSchemeFromUserDefaults() {
        UserDefaults.standard.set("light", forKey: Keys.colorScheme)
        let vm = SettingsViewModel(repository: MockProductRepository())
        #expect(vm.colorScheme == .light)
    }

    @Test func initRestoresLanguageFromUserDefaults() {
        UserDefaults.standard.set("gl", forKey: Keys.language)
        let vm = SettingsViewModel(repository: MockProductRepository())
        #expect(vm.language == .galician)
    }

    @Test func initFallsBackToSystemForUnknownColorScheme() {
        UserDefaults.standard.set("unknown", forKey: Keys.colorScheme)
        let vm = SettingsViewModel(repository: MockProductRepository())
        #expect(vm.colorScheme == .system)
    }

    @Test func initFallsBackToEnglishForUnknownLanguage() {
        UserDefaults.standard.set("unknown", forKey: Keys.language)
        let vm = SettingsViewModel(repository: MockProductRepository())
        #expect(vm.language == .english)
    }

    // MARK: Clear cache button

    @Test func clearCacheButtonOnTapSetsShowConfirmation() {
        let vm = SettingsViewModel(repository: MockProductRepository())
        vm.clearCacheButtonOnTap()
        #expect(vm.showClearCacheConfirmation == true)
    }

    // MARK: Clear cache — success

    @Test func clearCacheSetsCacheClearedOnSuccess() async {
        let vm = SettingsViewModel(repository: MockProductRepository())
        await vm.clearCache().value
        #expect(vm.cacheCleared == true)
    }

    @Test func clearCacheKeepsErrorNilOnSuccess() async {
        let vm = SettingsViewModel(repository: MockProductRepository())
        await vm.clearCache().value
        #expect(vm.clearCacheError == nil)
    }

    // MARK: Clear cache — failure

    @Test func clearCacheSetsErrorOnFailure() async {
        let vm = SettingsViewModel(repository: FailingClearCacheRepository())
        await vm.clearCache().value
        #expect(vm.clearCacheError != nil)
    }

    @Test func clearCacheDoesNotSetCacheClearedOnFailure() async {
        let vm = SettingsViewModel(repository: FailingClearCacheRepository())
        await vm.clearCache().value
        #expect(vm.cacheCleared == false)
    }

    // MARK: Dismiss handlers

    @Test func cacheClearedDismissedResetsCacheCleared() async {
        let vm = SettingsViewModel(repository: MockProductRepository())
        await vm.clearCache().value
        vm.cacheClearedDismissed()
        #expect(vm.cacheCleared == false)
    }

    @Test func clearCacheErrorDismissedResetsError() async {
        let vm = SettingsViewModel(repository: FailingClearCacheRepository())
        await vm.clearCache().value
        vm.clearCacheErrorDismissed()
        #expect(vm.clearCacheError == nil)
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

fileprivate final class FailingClearCacheRepository: ProductRepositoryProtocol {
    struct ClearCacheError: Error {}
    func fetchAll() async throws -> [Product] { [] }
    func fetch(category: ProductCategory?) async throws -> [Product] { [] }
    func fetchPage(skip: Int, limit: Int) async throws -> (products: [Product], total: Int) { ([], 0) }
    func clearCache() throws { throw ClearCacheError() }
}
