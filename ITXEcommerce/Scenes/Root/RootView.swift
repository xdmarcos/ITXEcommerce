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
                        Label(AppTab.catalog.title, systemImage: AppTab.catalog.systemImage)
                    }
                QuickStartView()
                    .tabItem {
                        Label(AppTab.quickStart.title, systemImage: AppTab.quickStart.systemImage)
                    }
                SettingsView()
                    .tabItem {
                        Label(AppTab.settings.title, systemImage: AppTab.settings.systemImage)
                    }
            }
        }
    }

    @available(iOS 26.0, *)
    @TabContentBuilder<AppTab>
    var tabs: some TabContent<AppTab> {
        catalogTab
        quickStartTab
        settingsTab
    }

    @available(iOS 26.0, *)
    var catalogTab: some TabContent<AppTab> {
        Tab(
            AppTab.catalog.title,
            systemImage: AppTab.catalog.systemImage,
            value: .catalog
        ) {
            CatalogView(repository: productRepository)
        }
    }

    @available(iOS 26.0, *)
    var quickStartTab: some TabContent<AppTab> {
        Tab(
            AppTab.quickStart.title,
            systemImage: AppTab.quickStart.systemImage,
            value: .quickStart
        ) {
            QuickStartView()
        }
    }

    @available(iOS 26.0, *)
    var settingsTab: some TabContent<AppTab> {
        Tab(
            AppTab.settings.title,
            systemImage: AppTab.settings.systemImage,
            value: .settings
        ) {
            SettingsView()
        }
    }
}
