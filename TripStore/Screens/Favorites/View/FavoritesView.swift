//
//  FavoritesView.swift
//  TripStore
//
//  Created by Mohamed Adel on 16/09/2026.
//

import SwiftUI
import Kingfisher

struct FavoritesView: View {

    @StateObject private var viewModel: FavoritesViewModel

    init(viewModel: FavoritesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackground()

            if viewModel.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.favorites) { product in
                            NavigationLink(value: AppRoute.product(product)) {
                                favoriteRow(product)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            viewModel.load()
        }
    }

    private func favoriteRow(_ product: Product) -> some View {
        HStack(spacing: 14) {
            thumbnail(for: product)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.category.capitalized)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.customGray.opacity(0.8))

                Text(product.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(product.price.formatted(.currency(code: "USD")))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }

            Spacer(minLength: 8)

            Button {
                viewModel.remove(product)
            } label: {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .font(.title3)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Remove \(product.title) from favorites")
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(product.title), \(product.category), \(product.price.formatted(.currency(code: "USD")))")
        .accessibilityHint("Opens product details")
    }

    private func thumbnail(for product: Product) -> some View {
        ZStack {
            Color.white.opacity(0.06)

            if let url = URL(string: product.thumbnail) {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(6)
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.system(size: 40))
                .foregroundStyle(.customGray.opacity(0.6))

            Text("No Favorites Yet")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Products you favorite will appear here.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.customGray.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    NavigationStack {
        FavoritesView(viewModel: FavoritesViewModel())
    }
}
