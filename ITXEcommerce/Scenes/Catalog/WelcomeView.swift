//
//  WelcomeView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 31/3/26.
//

import SwiftUI

struct WelcomeView: View {
    let title: String
    let description: String?
    let systemImage: String?

    var body: some View {
        VStack {
            if let image = systemImage {
                Image(systemName: image)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 16)
            }

            Text(title)
                .font(.title)

            if let desc = description {
                Text(desc)
                    .font(.title3)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    WelcomeView(title: "title", description: "description", systemImage: "square.grid.3x3")
}
