//
//  HomeView.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import SwiftUI

struct HomeView: View {

    @StateObject private var viewModel: HomeViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackground()

            content
        }
        .navigationTitle("🛍️ Trip Store")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            viewModel.loadInitial()
        }
        .navigationDestination(for: Product.self) { product in
            ProductDetailsView(viewModel: ProductDetailsViewModel(product: product))
        }
    }

    private var content: some View {
        VStack {
            
            categoryFilterBar
            
            switch viewModel.state {
                
            case .loading:
                skeletonGrid
                
            case .empty:
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .error(let error):
                errorStateView(error)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .loaded:
                productGrid
            }
        }
    }

    private var skeletonGrid: some View {

        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<8, id: \.self) { _ in
                    ProductCardView(product: nil)
                }
            }
            .padding(.horizontal)
            .padding(.top, 6)
            .padding(.bottom)
        }
        .accessibilityLabel("Loading products")
    }


    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {

                CategoryChip(title: "All", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectCategory(nil)
                }

                ForEach(viewModel.categories) { category in
                    CategoryChip(title: category.name, isSelected: viewModel.selectedCategory == category) {
                        viewModel.selectCategory(category)
                    }
                }
                
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }

    private var productGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.products) { product in
                    NavigationLink(value: product) {
                        ProductCardView(product: product)
                            .onAppear {
                                viewModel.loadNextPageIfNeeded(currentItem: product)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()

            if viewModel.isLoadingNextPage {
                ProgressView()
                    .padding(.vertical, 12)
                    .accessibilityLabel("Loading more products")
            }
        }
        .refreshable {
            viewModel.refresh()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .font(.system(size: 40))
            Text("No products found")
                .font(.headline)
        }
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .combine)
    }

    private func errorStateView(_ error: NetworkError) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.red)

            Text(error.errorDescription ?? "Something went wrong")
                .font(.subheadline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if error.isRetryable {
                Button("Retry") {
                    viewModel.refresh()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
