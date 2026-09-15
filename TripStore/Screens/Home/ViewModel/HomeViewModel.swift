//
//  HomeViewModel.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {

    @Published var products: [Product] = []
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var state: ViewState = .loading
    @Published var isLoadingNextPage = false
    @Published var isRefreshing = false

    private let useCase: HomeUseCaseProtocol
    private var hasMorePages = true
    private var totalAvailable = 0
    private let pageSize = 20
    private var nextSkip = 0

    private var loadTask: Task<Void, Never>?

    init(useCase: HomeUseCaseProtocol? = nil) {
        self.useCase = useCase ?? HomeUseCase()
    }

    func loadInitial() {
        guard products.isEmpty else { return }
        loadCategoriesIfNeeded()
        startLoad()
    }

    func refresh() {
        startLoad()
    }

    func selectCategory(_ category: Category?) {
        guard category != selectedCategory else { return }
        selectedCategory = category
        startLoad()
    }

    private func loadCategoriesIfNeeded() {
        guard categories.isEmpty else { return }
        Task {
            do {
                categories = try await useCase.loadCategories()
            } catch {
                
            }
        }
    }

    func loadNextPageIfNeeded(currentItem product: Product) {
        guard hasMorePages, !isLoadingNextPage else { return }
        guard let index = products.firstIndex(where: { $0.id == product.id }) else { return }

        let prefetchThreshold = 5
        if index >= products.count - prefetchThreshold {
            Task { await loadNextPage() }
        }
    }

    private func loadNextPage() async {
        guard hasMorePages, !isLoadingNextPage else { return }
        isLoadingNextPage = true
        defer { isLoadingNextPage = false }

        do {
            let response = try await fetchPage(skip: nextSkip)
            apply(response, replacing: false)
        } catch {

        }
    }

    private func startLoad() {

        loadTask?.cancel()
        state = .loading
        nextSkip = 0
        hasMorePages = true

        loadTask = Task {
            
            do {
                let response = try await fetchPage(skip: 0)
                guard !Task.isCancelled else { return }
                apply(response, replacing: true)

            } catch is CancellationError {

            } catch {
                guard !Task.isCancelled else { return }
                state = .error(mapError(error))
            }
        }
    }

    private func fetchPage(skip: Int) async throws -> ProductsResponse {
        if let categoryId = selectedCategory?.id {
            return try await useCase.loadProducts(category: categoryId, limit: pageSize, skip: skip)
        } else {
            return try await useCase.loadProducts(limit: pageSize, skip: skip)
        }
    }

    private func apply(_ response: ProductsResponse, replacing: Bool) {
        if replacing {
            products = response.products
        } else {
            products.append(contentsOf: response.products)
        }

        nextSkip = response.skip + response.products.count
        totalAvailable = response.total
        hasMorePages = !response.products.isEmpty && nextSkip < totalAvailable

        state = products.isEmpty ? .empty : .loaded
    }

    private func mapError(_ error: Error) -> NetworkError {
        (error as? NetworkError) ?? .unknown(error.localizedDescription)
    }
}
