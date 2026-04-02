//
//  RootView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 27/3/26.
//

import SwiftUI

struct RootView: View {
    @Environment(\.productRepository) private var productRepository
    @Environment(SettingsViewModel.self) private var settingsViewModel
    @State private var viewModel = RootViewModel()

    var body: some View {
        makeTabs()
            .preferredColorScheme(settingsViewModel.colorScheme.colorScheme)
            .environment(\.locale, settingsViewModel.language.locale)
    }
}

private extension RootView {
    @ViewBuilder
    func makeTabs() -> some View {
        if #available(iOS 26.0, *) {
            TabView(selection: $viewModel.selection) {
                tabs
            }
        } else {
            TabView {
                CatalogView(repository: productRepository)
                    .tabItem {
                        Label(AppTabConfig.catalog.title, systemImage: AppTabConfig.catalog.systemImage)
                    }
                QuickStartView()
                    .tabItem {
                        Label(AppTabConfig.quickStart.title, systemImage: AppTabConfig.quickStart.systemImage)
                    }
                SettingsView()
                    .tabItem {
                        Label(AppTabConfig.settings.title, systemImage: AppTabConfig.settings.systemImage)
                    }
            }
        }
    }

    @available(iOS 26.0, *)
    @TabContentBuilder<AppTabConfig>
    var tabs: some TabContent<AppTabConfig> {
        catalogTab
        quickStartTab
        settingsTab
    }

    @available(iOS 26.0, *)
    var catalogTab: some TabContent<AppTabConfig> {
        Tab(
            AppTabConfig.catalog.title,
            systemImage: AppTabConfig.catalog.systemImage,
            value: .catalog
        ) {
            CatalogView(repository: productRepository)
        }
    }

    @available(iOS 26.0, *)
    var quickStartTab: some TabContent<AppTabConfig> {
        Tab(
            AppTabConfig.quickStart.title,
            systemImage: AppTabConfig.quickStart.systemImage,
            value: .quickStart
        ) {
            QuickStartView()
        }
    }

    @available(iOS 26.0, *)
    var settingsTab: some TabContent<AppTabConfig> {
        Tab(
            AppTabConfig.settings.title,
            systemImage: AppTabConfig.settings.systemImage,
            value: .settings
        ) {
            SettingsView()
        }
    }
}
