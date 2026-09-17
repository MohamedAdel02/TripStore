//
//  SearchUseCase.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation
import Combine

struct SearchResult {
    let products: [Product]
    let availableCategories: [Category]?
}

protocol SearchUseCaseProtocol {
    func search(criteria: SearchCriteria) async throws -> SearchResult
}


class SearchUseCase: SearchUseCaseProtocol {

    private let repository: SearchRepositoryProtocol

    private var categoryCache: [String: [Product]] = [:]
    private var generalResultsCache: [String: [Product]] = [:]

    init(repository: SearchRepositoryProtocol = SearchRepository()) {
        self.repository = repository
    }

    func search(criteria: SearchCriteria) async throws -> SearchResult {
        let trimmedQuery = criteria.query.trimmingCharacters(in: .whitespacesAndNewlines)

        if let categoryId = criteria.category?.id {

            let categoryProducts = try await cachedCategoryProducts(for: categoryId)

            var candidates = categoryProducts.filter {
                $0.title.localizedCaseInsensitiveContains(trimmedQuery)
            }

            if criteria.minRating > 0 {
                candidates = candidates.filter { $0.rating >= criteria.minRating }
            }

            candidates = Self.sort(candidates, by: criteria.sort)

            return SearchResult(products: candidates, availableCategories: nil)
        }

        let generalResults = try await cachedGeneralResults(for: trimmedQuery)
        let titleMatches = generalResults.filter {
            $0.title.localizedCaseInsensitiveContains(trimmedQuery)
        }
        let availableCategories = Self.extractCategories(from: titleMatches)

        var candidates = titleMatches

        if criteria.minRating > 0 {
            candidates = candidates.filter { $0.rating >= criteria.minRating }
        }

        candidates = Self.sort(candidates, by: criteria.sort)

        return SearchResult(products: candidates, availableCategories: availableCategories)
    }


    private func cachedGeneralResults(for query: String) async throws -> [Product] {
        let key = query.lowercased()
        if let cached = generalResultsCache[key] { return cached }
        let results = try await repository.searchAll(query: query)
        generalResultsCache[key] = results
        return results
    }

    private func cachedCategoryProducts(for slug: String) async throws -> [Product] {
        if let cached = categoryCache[slug] { return cached }
        let products = try await repository.fetchByCategory(id: slug)
        categoryCache[slug] = products
        return products
    }

    private static func sort(_ products: [Product], by option: SortOption) -> [Product] {
        switch option {
        case .none:
            return products
        case .priceAscending:
            return products.sorted { $0.price < $1.price }
        case .priceDescending:
            return products.sorted { $0.price > $1.price }
        case .ratingAscending:
            return products.sorted { $0.rating < $1.rating }
        case .ratingDescending:
            return products.sorted { $0.rating > $1.rating }
        }
    }

    private static func extractCategories(from products: [Product]) -> [Category] {
        let uniqueSlugs = Set(products.map(\.category))
        return uniqueSlugs
            .map { slug in
                Category(
                    id: slug,
                    name: prettify(slug),
                    url: "https://dummyjson.com/products/category/\(slug)"
                )
            }
            .sorted { $0.name < $1.name }
    }

    private static func prettify(_ slug: String) -> String {
        slug
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}
