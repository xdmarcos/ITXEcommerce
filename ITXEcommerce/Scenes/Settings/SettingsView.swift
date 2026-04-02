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
                        bindableViewModel.clearCacheButtonOnTap()
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Clear Cache",
                isPresented: $bindableViewModel.showClearCacheConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear", role: .destructive) { bindableViewModel.clearCache() }
            } message: {
                Text("This will remove all locally cached product data. It will be re-downloaded on next use.")
            }
            .alert("Cache Cleared", isPresented: Binding(
                get: { bindableViewModel.cacheCleared },
                set: { if !$0 { bindableViewModel.cacheClearedDismissed() } }
            )) {
                Button("OK") { bindableViewModel.cacheClearedDismissed() }
            } message: {
                Text("The product cache has been cleared successfully.")
            }
            .alert("Error", isPresented: Binding(
                get: { bindableViewModel.clearCacheError != nil },
                set: { if !$0 { bindableViewModel.clearCacheErrorDismissed() } }
            ), presenting: bindableViewModel.clearCacheError) { _ in
                Button("OK", role: .cancel) { bindableViewModel.clearCacheErrorDismissed() }
            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(SettingsViewModel(repository: MockProductRepository()))
}
