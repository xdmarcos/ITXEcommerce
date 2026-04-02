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
                CachedAsyncImage(url: URL(string: images[index])) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Rectangle()
                        .foregroundStyle(.secondary.opacity(0.12))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.tertiary)
                                .font(.largeTitle)
                        }
                }
                .tag(index)
                .clipped()
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .overlay(alignment: .bottom) {
            PageIndicatorView(count: images.count, current: currentImageIndex.wrappedValue)
                .padding(.bottom, 16)
        }
    }
}

// MARK: - Preview

#Preview {
    ImageGalleryView(
        images: [
            "https://picsum.photos/seed/acc005ntr1/400/600",
            "https://picsum.photos/seed/acc005ntr2/400/600",
            "https://picsum.photos/seed/acc005ntr3/400/600"
        ], currentImageIndex: .constant(0)
    )
}
