//
//  NetworkHelper.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation

enum APIEnvironment {

    case production

    var baseURL: String {
        switch self {
        case .production:
            return "https://dummyjson.com/"
        }
    }
}

enum HTTPMethod: String {

    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct HTTPRequest {

    var url: URL
    var method: HTTPMethod = .get
    var body: Data?
    var headers: [String: String] = [:]
}

struct ProductQuery {

    var limit: Int?
    var skip: Int?
    var sortBy: String?      // "price", "rating", "title"
    var order: String?       // "asc" or "desc"
    var select: [String]?    // comma-joined field list

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        if let skip {
            items.append(URLQueryItem(name: "skip", value: String(skip)))
        }
        if let sortBy {
            items.append(URLQueryItem(name: "sortBy", value: sortBy))
        }
        if let order {
            items.append(URLQueryItem(name: "order", value: order))
        }
        if let select, !select.isEmpty {
            items.append(URLQueryItem(name: "select", value: select.joined(separator: ",")))
        }
        return items
    }
}

enum ProductEndpoint {

    case all(query: ProductQuery = ProductQuery())
    case detail(id: Int)
    case search(query: String, paging: ProductQuery = ProductQuery())
    case categories
    case categoryList
    case byCategory(slug: String, paging: ProductQuery = ProductQuery())

    private var environment: APIEnvironment { .production }

    private var path: String {
        switch self {
        case .all:
            return "products"
        case .detail(let id):
            return "products/\(id)"
        case .search:
            return "products/search"
        case .categories:
            return "products/categories"
        case .categoryList:
            return "products/category-list"
        case .byCategory(let slug, _):
            return "products/category/\(slug)"
        }
    }

    private var queryItems: [URLQueryItem] {
        switch self {
        case .all(let query):
            return query.queryItems

        case .detail, .categories, .categoryList:
            return []

        case .search(let q, let paging):
            var items = [URLQueryItem(name: "q", value: q)]
            items.append(contentsOf: paging.queryItems)
            return items

        case .byCategory(_, let paging):
            return paging.queryItems
        }
    }

    func asHTTPRequest() throws -> HTTPRequest {
        let fullURLString = environment.baseURL + path

        guard var components = URLComponents(string: fullURLString) else {
            throw NetworkError.invalidURL
        }

        let items = queryItems
        components.queryItems = items.isEmpty ? nil : items

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        return HTTPRequest(url: url, method: .get)
    }
}
