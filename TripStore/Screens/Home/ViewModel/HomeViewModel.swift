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

    private let useCase: HomeUseCaseProtocol
    private var hasMorePages = true
    private var totalAvailable = 0
    private let pageSize = 20
    private let minimumLoadingDuration: Duration = .milliseconds(750)
    private var nextSkip = 0

    private var loadTask: Task<Void, Never>?

    init(useCase: HomeUseCaseProtocol? = nil) {
        self.useCase = useCase ?? HomeUseCase()
    }

    func loadInitial() {
        guard products.isEmpty else { return }
        loadCategoriesIfNeeded()
        startLoad(useMinimumLoadingDuration: true)
    }

    func refresh() async {
        loadCategoriesIfNeeded()
        await startLoadAndWait(useMinimumLoadingDuration: true)
    }

    func selectCategory(_ category: Category?) {
        guard category != selectedCategory else { return }
        selectedCategory = category
        startLoad(useMinimumLoadingDuration: false)
    }

    private func loadCategoriesIfNeeded() {
        Task {
            do {
                let fetched = try await useCase.loadCategories()
                if !fetched.isEmpty {
                    self.categories = fetched
                }
            } catch {
                // Silently ignore category failures in offline mode
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
            // Silently keep existing pagination when offline
        }
    }

    private func startLoad(useMinimumLoadingDuration: Bool) {
        loadTask?.cancel()
        loadTask = Task {
            await performLoad(useMinimumLoadingDuration: useMinimumLoadingDuration)
        }
    }

    private func startLoadAndWait(useMinimumLoadingDuration: Bool) async {
        loadTask?.cancel()
        let task = Task {
            await performLoad(useMinimumLoadingDuration: useMinimumLoadingDuration)
        }
        loadTask = task
        await task.value
    }

    private func performLoad(useMinimumLoadingDuration: Bool) async {
        state = .loading
        nextSkip = 0
        hasMorePages = true

        let startedAt = ContinuousClock.now

        do {
            let response = try await fetchPage(skip: 0)
            if useMinimumLoadingDuration {
                try await waitForMinimumLoadingDuration(since: startedAt)
            }
            guard !Task.isCancelled else { return }
            apply(response, replacing: true)

        } catch is CancellationError {

        } catch {
            guard !Task.isCancelled else { return }
            state = .error(mapError(error))
        }
    }

    private func waitForMinimumLoadingDuration(since startedAt: ContinuousClock.Instant) async throws {
        let elapsed = ContinuousClock.now - startedAt
        let remaining = minimumLoadingDuration - elapsed
        guard remaining > .zero else { return }
        try await Task.sleep(for: remaining)
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
