//
//  SearchView.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import SwiftUI

struct SearchView: View {

    @StateObject private var viewModel: SearchViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                categoryFilterBar
                orderAndRatingBar
                expandedPanel
                results
            }
            .animation(.spring(response: 0.35, dampingFraction: 1.3), value: viewModel.expandedPanel)
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .searchable(text: $viewModel.searchText, prompt: "Search products")
        .navigationDestination(for: Product.self) { product in
            ProductDetailsView(viewModel: ProductDetailsViewModel(product: product))
        }
    }


    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(title: "All", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }

                ForEach(viewModel.availableCategories) { category in
                    CategoryChip(title: category.name, isSelected: viewModel.selectedCategory == category) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }

    private var orderAndRatingBar: some View {
        HStack(spacing: 8) {
            orderChip
                .frame(maxWidth: .infinity)
            ratingChip
                .frame(maxWidth: .infinity)

            if viewModel.isFilterResetAvailable {
                resetButton
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var orderChip: some View {
        Button {
            viewModel.toggleOrderPanel()
        } label: {
            ChipLabel(
                title: "Order",
                isActive: viewModel.sortOption != .none || viewModel.expandedPanel == .order,
                fullWidth: true
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Order: \(viewModel.sortOption.displayName)")
        .accessibilityAddTraits(viewModel.expandedPanel == .order ? [.isSelected] : [])
    }

    private var ratingChip: some View {
        Button {
            viewModel.toggleRatingPanel()
        } label: {
            ChipLabel(
                title: ratingChipTitle,
                isActive: viewModel.minRating > 0 || viewModel.expandedPanel == .rating,
                fullWidth: true
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Rating filter, currently \(ratingChipTitle)")
        .accessibilityAddTraits(viewModel.expandedPanel == .rating ? [.isSelected] : [])
    }

    private var ratingChipTitle: String {
        viewModel.minRating > 0 ? "Rating \(String(format: "%.1f", viewModel.minRating))+" : "Rating"
    }

    private var resetButton: some View {
        Button {
            viewModel.resetFilters()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.customGray.opacity(0.8))
        }
        .accessibilityLabel("Reset filters and sort")
    }

    @ViewBuilder
    private var expandedPanel: some View {
        switch viewModel.expandedPanel {
        case .none:
            EmptyView()
        case .order:
            orderOptionsPanel
                .transition(.opacity.combined(with: .move(edge: .top)))
        case .rating:
            ratingSlider
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    private var orderOptionsPanel: some View {
        VStack(spacing: 8) {
            ForEach(SortOption.allCases) { option in
                SortOptionRow(
                    option: option,
                    isSelected: viewModel.sortOption == option
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        viewModel.sortOption = option
                        viewModel.collapsePanel()
                    }
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
        .padding(.bottom, 10)
    }

    private var ratingSlider: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Minimum rating")
                    .font(.caption)
                    .foregroundStyle(Color.customGray.opacity(0.9))
                Spacer()
                Text(viewModel.minRating > 0 ? String(format: "%.1f+", viewModel.minRating) : "Any")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }

            Slider(value: $viewModel.minRating, in: 0...5, step: 0.5)
                .tint(.customGray)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal)
        .padding(.bottom, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Minimum rating slider, currently \(viewModel.minRating > 0 ? String(format: "%.1f", viewModel.minRating) : "any")")
    }

    @ViewBuilder
    private var results: some View {
        switch viewModel.state {
        case .idle:
            idleStateView
                .frame(maxWidth: .infinity, maxHeight: .infinity)

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

    private var idleStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
            Text(viewModel.idlePromptText)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .foregroundStyle(Color.customGray.opacity(0.8))
        .accessibilityElement(children: .combine)
    }

    private var skeletonGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<8, id: \.self) { _ in
                    ProductCardView(product: nil)
                }
            }
            .padding()
        }
        .accessibilityLabel("Loading results")
    }

    private var productGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.products) { product in
                    NavigationLink(value: product) {
                        ProductCardView(product: product)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .font(.system(size: 40))
            Text("No products match your search")
                .font(.headline)

            Button("Reset Filters") {
                viewModel.resetFilters()
            }
            .buttonStyle(.bordered)
        }
        .foregroundStyle(Color.customGray.opacity(0.8))
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
                    viewModel.retry()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct SortOptionRow: View {
    let option: SortOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: option.iconName)
                    .font(.subheadline)
                    .frame(width: 20)

                Text(option.displayName)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.subheadline)
                }
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.accentColor : Color.gray.opacity(0.15))
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
