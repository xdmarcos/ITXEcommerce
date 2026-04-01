//
//  FavoritesView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct QuickStartView: View {
    @State private var viewModel = QuickStartViewModel()

    var body: some View {
        ScrollView {
            MarkdownView(content: viewModel.readmeContent)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    NavigationStack {
        QuickStartView()
    }
}
