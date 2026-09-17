//
//  SearchRepository.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation

protocol SearchRepositoryProtocol {

    func searchAll(query: String) async throws -> [Product]
    func fetchByCategory(id: String) async throws -> [Product]
}

class SearchRepository: SearchRepositoryProtocol {

    private let networkManager: NetworkManager
    private let fetchLimit = 30

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    func searchAll(query: String) async throws -> [Product] {
        let request = try ProductEndpoint
            .search(query: query, paging: ProductQuery(limit: fetchLimit))
            .asHTTPRequest()
        let response = try await networkManager.send(request, as: ProductsResponse.self)
        return response.products
    }

    func fetchByCategory(id: String) async throws -> [Product] {
        let request = try ProductEndpoint
            .byCategory(id: id, paging: ProductQuery(limit: fetchLimit))
            .asHTTPRequest()
        let response = try await networkManager.send(request, as: ProductsResponse.self)
        return response.products
    }
}
