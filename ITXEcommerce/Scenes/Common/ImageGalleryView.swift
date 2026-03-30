//
//  ImageGalleryView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 30/3/26.
//

import SwiftUI

struct ImageGalleryView: View {
    private let images: [String]
    private var currentImageIndex: Binding<Int>

    init(images: [String], currentImageIndex: Binding<Int>) {
        self.images = images
        self.currentImageIndex = currentImageIndex
    }

    var body: some View {
        TabView(selection: currentImageIndex) {
            ForEach(images.indices, id: \.self) { index in
                AsyncImage(url: URL(string: images[index])) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Rectangle()
                            .foregroundStyle(.secondary.opacity(0.12))
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundStyle(.tertiary)
                                    .font(.largeTitle)
                            }
                    }
                }
                .tag(index)
                .clipped()
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
    }
}

// MARK: - Preview

#Preview {
    ImageGalleryView(
        images: [
            "https://picsum.photos/seed/acc005ntr1/400/600",
            "https://picsum.photos/seed/acc005ntr2/400/600"
        ], currentImageIndex: .constant(0)
    )
}
