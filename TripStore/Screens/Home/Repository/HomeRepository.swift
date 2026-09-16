//
//  HomeRepository.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation

protocol HomeRepositoryProtocol {
    func fetchProducts(limit: Int, skip: Int) async throws -> ProductsResponse
    func fetchProducts(category: String, limit: Int, skip: Int) async throws -> ProductsResponse
    func fetchCategories() async throws -> [Category]
}

class HomeRepository: HomeRepositoryProtocol {

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    func fetchProducts(limit: Int, skip: Int) async throws -> ProductsResponse {
        let query = ProductQuery(limit: limit, skip: skip)
        let request = try ProductEndpoint.all(query: query).asHTTPRequest()
        return try await networkManager.send(request, as: ProductsResponse.self)
    }

    func fetchProducts(category: String, limit: Int, skip: Int) async throws -> ProductsResponse {
        let query = ProductQuery(limit: limit, skip: skip)
        let request = try ProductEndpoint.byCategory(id: category, paging: query).asHTTPRequest()
        return try await networkManager.send(request, as: ProductsResponse.self)
    }

    func fetchCategories() async throws -> [Category] {
        let request = try ProductEndpoint.categories.asHTTPRequest()
        return try await networkManager.send(request, as: [Category].self)
    }
}
