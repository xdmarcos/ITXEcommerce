//
//  RootView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 27/3/26.
//

import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selection: AppTab = .catalog

    var body: some View {
        makeTabs()
    }
}

private extension RootView {
    @ViewBuilder
    func makeTabs() -> some View {
        if #available(iOS 26.0, *) {
            TabView(selection: $selection) {
                tabs
            }
        } else {
            TabView {
                CatalogView()
                    .tabItem {
                        Label(AppTab.catalog.title, systemImage: AppTab.catalog.systemImage)
                    }
                FavoritesView()
                    .tabItem {
                        Label(AppTab.favorites.title, systemImage: AppTab.favorites.systemImage)
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
        favoritesTab
        settingsTab
    }

    @available(iOS 26.0, *)
    var catalogTab: some TabContent<AppTab> {
        Tab(
            AppTab.catalog.title,
            systemImage: AppTab.catalog.systemImage,
            value: .catalog
        ) {
            CatalogView()
        }
    }

    @available(iOS 26.0, *)
    var favoritesTab: some TabContent<AppTab> {
        Tab(
            AppTab.favorites.title,
            systemImage: AppTab.favorites.systemImage,
            value: .favorites
        ) {
            FavoritesView()
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
