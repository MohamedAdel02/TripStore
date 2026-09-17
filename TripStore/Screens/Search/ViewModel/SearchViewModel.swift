//
//  SearchViewModel.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {

    enum ExpandedPanel: Equatable {
        case none
        case order
        case rating
    }

    @Published var searchText: String = "" {
        didSet {
            guard searchText != oldValue else { return }

            if selectedCategory != nil {
                isBulkUpdating = true
                selectedCategory = nil
                isBulkUpdating = false
            }
            scheduleDebouncedSearch()
        }
    }

    @Published var selectedCategory: Category? {
        didSet {
            guard selectedCategory != oldValue else { return }
            guard !isBulkUpdating else { return }
            reload()
        }
    }

    @Published var minRating: Double = 0 {
        didSet {
            guard minRating != oldValue else { return }
            guard !isBulkUpdating else { return }
            reload()
        }
    }

    @Published var sortOption: SortOption = .none {
        didSet {
            guard sortOption != oldValue else { return }
            guard !isBulkUpdating else { return }
            reload()
        }
    }

    @Published var expandedPanel: ExpandedPanel = .none

    private var isBulkUpdating = false

    @Published var products: [Product] = []
    @Published var availableCategories: [Category] = []
    @Published var state: ViewState = .idle

    private let useCase: SearchUseCaseProtocol
    private let debounceNanoseconds: UInt64 = 400_000_000

    private var debounceTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    private var searchGeneration = 0

    init(useCase: SearchUseCaseProtocol? = nil) {
        self.useCase = useCase ?? SearchUseCase()
    }

    var currentCriteria: SearchCriteria {
        SearchCriteria(query: searchText, category: selectedCategory, minRating: minRating, sort: sortOption)
    }
    var isFilterResetAvailable: Bool {
        selectedCategory != nil || minRating > 0 || sortOption != .none
    }

    var idlePromptText: String {
        let criteria = currentCriteria
        let hasFiltersOnly = criteria.category != nil || criteria.minRating > 0 || criteria.sort != .none
        return hasFiltersOnly
            ? "Type something to search within your selected filters"
            : "Search, then refine with filters"
    }

    func toggleOrderPanel() {
        expandedPanel = (expandedPanel == .order) ? .none : .order
    }

    func toggleRatingPanel() {
        expandedPanel = (expandedPanel == .rating) ? .none : .rating
    }

    func collapsePanel() {
        expandedPanel = .none
    }

    private func scheduleDebouncedSearch() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: debounceNanoseconds)
            guard !Task.isCancelled else { return }
            reload()
        }
    }

    private func reload() {
        debounceTask?.cancel()
        searchTask?.cancel()
        searchGeneration += 1
        let generation = searchGeneration

        let criteria = currentCriteria
        let trimmedQuery = criteria.query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedQuery.isEmpty else {
            products = []
            availableCategories = []
            state = .idle
            return
        }

        state = .loading

        if criteria.category == nil {
            availableCategories = []
        }

        searchTask = Task {
            do {
                let result = try await useCase.search(criteria: criteria)
                guard generation == searchGeneration else { return }
                if let categories = result.availableCategories {
                    availableCategories = categories
                }
                products = result.products
                state = result.products.isEmpty ? .empty : .loaded
            } catch is CancellationError {
                return
            } catch {
                guard generation == searchGeneration else { return }
                if let networkError = error as? NetworkError, case .cancelled = networkError {
                    return
                }
                state = .error((error as? NetworkError) ?? .unknown(error.localizedDescription))
            }
        }
    }

    func retry() {
        reload()
    }

    func resetFilters() {
        isBulkUpdating = true
        selectedCategory = nil
        minRating = 0
        sortOption = .none
        isBulkUpdating = false
        expandedPanel = .none

        reload()
    }
}
