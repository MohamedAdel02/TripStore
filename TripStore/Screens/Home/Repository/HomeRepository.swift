//
//  HomeRepository.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation
import RealmSwift

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
        
        do {
            let response = try await networkManager.send(request, as: ProductsResponse.self)
            await saveProductsToLocalCache(response.products)
            return response
        } catch {
            let cachedProducts = await getLocalCachedProducts()
            if !cachedProducts.isEmpty {
                let filtered = skip < cachedProducts.count ? Array(cachedProducts.suffix(from: skip).prefix(limit)) : []
                return ProductsResponse(products: filtered, total: cachedProducts.count, skip: skip, limit: limit)
            }
            throw error
        }
    }

    func fetchProducts(category: String, limit: Int, skip: Int) async throws -> ProductsResponse {
        let query = ProductQuery(limit: limit, skip: skip)
        let request = try ProductEndpoint.byCategory(id: category, paging: query).asHTTPRequest()
        
        do {
            let response = try await networkManager.send(request, as: ProductsResponse.self)
            await saveProductsToLocalCache(response.products)
            return response
        } catch {
            let cachedProducts = await getLocalCachedProducts(category: category)
            if !cachedProducts.isEmpty {
                let filtered = skip < cachedProducts.count ? Array(cachedProducts.suffix(from: skip).prefix(limit)) : []
                return ProductsResponse(products: filtered, total: cachedProducts.count, skip: skip, limit: limit)
            }
            throw error
        }
    }

    func fetchCategories() async throws -> [Category] {
        let request = try ProductEndpoint.categories.asHTTPRequest()
        do {
            return try await networkManager.send(request, as: [Category].self)
        } catch {
            // Return empty list on network failure so cached products still load
            return []
        }
    }

    // MARK: - Realm Cache Helpers (Thread-Safe)
    
    @MainActor
    private func saveProductsToLocalCache(_ products: [Product]) {
        guard let realm = try? Realm() else { return }
        do {
            try realm.write {
                for product in products {
                    realm.add(ProductObject(product), update: .modified)
                }
            }
        } catch {
            print("Failed to write products to Realm: \(error)")
        }
    }

    @MainActor
    private func getLocalCachedProducts(category: String? = nil) -> [Product] {
        guard let realm = try? Realm() else { return [] }
        var objects = realm.objects(ProductObject.self)
        if let category = category {
            objects = objects.filter("category == %@", category)
        }
        return objects.map { $0.asProduct }
    }
}
