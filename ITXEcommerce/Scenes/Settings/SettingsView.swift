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
        @Bindable var viewModel = viewModel
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $viewModel.colorScheme) {
                        ForEach(AppColorScheme.allCases, id: \.self) { scheme in
                            Text(scheme.title).tag(scheme)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init())
                }

                Section("Language") {
                    Picker("Language", selection: $viewModel.language) {
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
                isPresented: $viewModel.showClearCacheConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear", role: .destructive) { viewModel.clearCache() }
                Button("Cancel", role: .cancel) {}
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
            .alert("Error", isPresented: Binding(
                get: { viewModel.clearCacheError != nil },
                set: { if !$0 { viewModel.clearCacheErrorDismissed() } }
            ), presenting: viewModel.clearCacheError) { _ in
                Button("OK", role: .cancel) { viewModel.clearCacheErrorDismissed() }
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
