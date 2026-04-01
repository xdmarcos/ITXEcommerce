//
//  CachedAsyncImage.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 1/4/26.
//

import SwiftUI

private final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()
    private let cache = NSCache<NSURL, UIImage>()

    func configure(memoryCostLimit: Int) {
        cache.totalCostLimit = memoryCostLimit
    }

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func store(_ image: UIImage, for url: URL) {
        let cost = Int(image.size.width * image.size.height * image.scale * image.scale) * 4
        cache.setObject(image, forKey: url as NSURL, cost: cost)
    }
}

enum CachedAsyncImageConfiguration {
    static func setMemoryCostLimit(_ limit: Int) {
        ImageCache.shared.configure(memoryCostLimit: limit)
    }
}

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        if let uiImage {
            content(Image(uiImage: uiImage))
        } else {
            placeholder()
                .task(id: url) { await load() }
        }
    }

    private func load() async {
        guard let url else { return }
        if let cached = ImageCache.shared.image(for: url) {
            uiImage = cached
            return
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let loaded = UIImage(data: data) else { return }
        ImageCache.shared.store(loaded, for: url)
        uiImage = loaded
    }
}
