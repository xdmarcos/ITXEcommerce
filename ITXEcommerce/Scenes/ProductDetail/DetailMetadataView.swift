//
//  DetailMetadataView.swift
//  ITXEcommerce
//
//  Created by xdmGzDev on 1/4/26.
//

import SwiftUI

struct DetailMetadataView: View {
    var viewModel: ProductDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 16) {
                Label(viewModel.product.rating.formatted(.number.precision(.fractionLength(1))), systemImage: "star.fill")
                    .font(.subheadline)
                    .foregroundStyle(.orange)

                if viewModel.product.discountPercentage > 0 {
                    Label(
                        "-\(viewModel.product.discountPercentage.formatted(.number.precision(.fractionLength(0))))%",
                        systemImage: "tag.fill"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.green)
                }

                Label("\(viewModel.product.stock) in stock", systemImage: "shippingbox")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !viewModel.product.tags.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.product.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.secondary.opacity(0.12))
                                .clipShape(.capsule)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}
