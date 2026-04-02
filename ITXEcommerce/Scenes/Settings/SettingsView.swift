//
//  SettingsView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(SettingsViewModel.self) private var viewModel

    var body: some View {
        @Bindable var bindableViewModel = viewModel
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $bindableViewModel.colorScheme) {
                        ForEach(AppColorScheme.allCases, id: \.self) { scheme in
                            Text(scheme.title).tag(scheme)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init())
                }

                Section("Language") {
                    Picker("Language", selection: $bindableViewModel.language) {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Text(lang.title).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init())
                }

                Section("Data") {
                    Button("Clear Cache", role: .destructive) {
                        viewModel.clearCacheButtonOnTap()
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Clear Cache",
                isPresented: $bindableViewModel.showClearCacheConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear", role: .destructive) { viewModel.clearCache() }
            } message: {
                Text("This will remove all locally cached product data. It will be re-downloaded on next use.")
            }
            .alert("Cache Cleared", isPresented: Binding(
                get: { viewModel.cacheCleared },
                set: { if !$0 { viewModel.cacheClearedDismissed() } }
            )) {
                Button("OK") { viewModel.cacheClearedDismissed() }
            } message: {
                Text("The product cache has been cleared successfully.")
            }
            .errorAlert(
                error: Binding(
                    get: { viewModel.settingsError },
                    set: { if $0 != nil { viewModel.clearCacheError() } }
                )
            )
        }
    }
}

#Preview {
    SettingsView()
        .environment(SettingsViewModel(cacheManager: NullCacheManageable()))
}
