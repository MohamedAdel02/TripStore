//
//  ProductDetailsView.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import SwiftUI
import Kingfisher

struct ProductDetailsView: View {

    @StateObject private var viewModel: ProductDetailsViewModel

    init(viewModel: ProductDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    imageGallery

                    header

                    if let description = viewModel.product.description, !description.isEmpty {
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.customGray.opacity(0.8))
                    }

                    Divider()
                        .background(.customGray.opacity(0.8))

                    quantitySection

                    totalSection
                }
                .padding()
            }
        }
        .navigationTitle(viewModel.product.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var imageGallery: some View {
        Group {
            if viewModel.galleryURLs.isEmpty {
                placeholderImage
            } else {
                TabView {
                    ForEach(viewModel.galleryURLs, id: \.self) { url in
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 280)
            }
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Product image gallery, \(viewModel.galleryURLs.count) photos")
    }

    private var placeholderImage: some View {
        ZStack {
            Color.customGray.opacity(0.8)
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
        }
        .frame(height: 280)
    }

    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.product.category.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.customGray.opacity(0.8))

            Text(viewModel.product.title)
                .font(.title2)
                .bold()
                .foregroundStyle(.white)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text(String(format: "%.1f", viewModel.product.rating))

                Spacer()

                stockLabel
            }
            .font(.subheadline)
            .foregroundStyle(.customGray.opacity(0.8))

            Text(viewModel.product.price.formatted(.currency(code: "USD")))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .accessibilityElement(children: .combine)
    }

    private var stockLabel: some View {
        Group {
            if viewModel.isOutOfStock {
                Text("Out of Stock")
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
            } else {
                Text("\(viewModel.product.stock) in stock")
            }
        }
    }

    private var quantitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quantity")
                .font(.headline)
                .foregroundStyle(.white)

            HStack(spacing: 20) {
                Button {
                    viewModel.decrement()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(viewModel.canDecrement ? .white : .customGray.opacity(0.6))
                }
                .disabled(!viewModel.canDecrement)
                .accessibilityLabel("Decrease quantity")

                Text("\(viewModel.quantity)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(minWidth: 32)
                    .foregroundStyle(!viewModel.isOutOfStock ? .white : .customGray.opacity(0.4))

                Button {
                    viewModel.increment()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(viewModel.canIncrement ? .white : .customGray.opacity(0.6))

                }
                .disabled(!viewModel.canIncrement)
                .accessibilityLabel("Increase quantity")
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Quantity \(viewModel.quantity) of \(viewModel.maxQuantity) available")
        }
    }

    private var totalSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text(viewModel.formattedTotalPrice)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.white)
            .padding(.bottom)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Total \(viewModel.formattedTotalPrice)")

            NavigationLink {

                OrderConfirmationView(product: viewModel.product, quantity: viewModel.quantity)
            } label: {
                Text(viewModel.isOutOfStock ? "Out of Stock" : "Add to Order")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .foregroundStyle(viewModel.canOrder ? .white : .white.opacity(0.8))
                    .background(viewModel.canOrder ? Color.accentColor : Color.white.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canOrder)
        }
    }
}
