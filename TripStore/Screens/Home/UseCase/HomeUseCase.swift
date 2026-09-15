//
//  HomeUseCase.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation

protocol HomeUseCaseProtocol {
    func loadProducts(limit: Int, skip: Int) async throws -> ProductsResponse
    func loadProducts(category: String, limit: Int, skip: Int) async throws -> ProductsResponse
    func loadCategories() async throws -> [Category]
}

class HomeUseCase: HomeUseCaseProtocol {

    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol = HomeRepository()) {
        self.repository = repository
    }

    func loadProducts(limit: Int, skip: Int) async throws -> ProductsResponse {
        try await repository.fetchProducts(limit: limit, skip: skip)
    }

    func loadProducts(category: String, limit: Int, skip: Int) async throws -> ProductsResponse {
        try await repository.fetchProducts(category: category, limit: limit, skip: skip)
    }

    func loadCategories() async throws -> [Category] {
        try await repository.fetchCategories()
    }
}
