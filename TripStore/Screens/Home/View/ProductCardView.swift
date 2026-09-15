//
//  ProductCardView.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//


import SwiftUI
import UIKit
import Kingfisher
import SkeletonUI


struct ProductCardView: View {

    let product: Product?

    @State private var isImageLoading = true
    private var isLoading: Bool { product == nil }
    
    private var displayProduct: Product {
        product ?? .skeletonPlaceholder
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            thumbnail

            Text(displayProduct.category.capitalized)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.customGray.opacity(0.8))
                .lineLimit(1)
                .redacted(reason: isLoading ? .placeholder : [])
                .addSkelton(isLoading)


            Text(displayProduct.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: twoLineTitleHeight, alignment: .top)
                .redacted(reason: isLoading ? .placeholder : [])
                .addSkelton(isLoading)

            HStack(alignment: .top, spacing: 8) {
                ratingView
                    .addSkelton(isLoading)

                Spacer(minLength: 8)
                Text(priceText)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .multilineTextAlignment(.trailing)
                    .redacted(reason: isLoading ? .placeholder : [])
                    .addSkelton(isLoading)

            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHidden(isLoading)
    }

    private var thumbnail: some View {
        ZStack {
            if isLoading {
                Rectangle()
                    .addSkelton(isLoading)
            }

            if let product {
                KFImage(URL(string: product.thumbnail))
                    .retry(maxCount: 2, interval: .seconds(1))
                    .fade(duration: 0.2)
                    .onSuccess { _ in isImageLoading = false }
                    .onFailure { _ in isImageLoading = false }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(isImageLoading ? 0 : 1)
            }
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var ratingView: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundStyle(.yellow)
            
            Text(String(format: "%.1f", displayProduct.rating))
                .font(.caption)
                .foregroundStyle(.customGray.opacity(0.8))
        }
    }

    private var priceText: String {
        displayProduct.price.formatted(.currency(code: "USD"))
    }

    private var twoLineTitleHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .subheadline).lineHeight * 2.4
    }

    private var accessibilityDescription: String {
        "\(displayProduct.title), \(displayProduct.category), rated \(String(format: "%.1f", displayProduct.rating)) out of 5, \(priceText)"
    }
}



private extension Product {

    static let skeletonPlaceholder = Product(id: -1, title: "Placeholder Product Title", description: nil, category: "Category", price: 0, discountPercentage: nil, rating: 0, stock: 0, brand: nil, thumbnail: "", images: nil)
    
}
