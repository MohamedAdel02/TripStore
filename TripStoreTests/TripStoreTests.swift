//
//  TripStoreTests.swift
//  TripStoreTests
//


import XCTest
@testable import TripStore

@MainActor
class TripStoreTests: XCTestCase {

    // MARK: - 1. Price calculation, rounding

    func test_priceMath_subtotalRoundsToTwoDecimalPlaces() {
        // 33.333 * 3 = 99.999 -> should round to 100.00
        XCTAssertEqual(PriceMath.subtotal(unitPrice: 33.333, quantity: 3), 100.00, accuracy: 0.001)
    }

    func test_priceMath_serviceFeeIsFivePercentRounded() {
        // 5% of 19.99 = 0.9995 -> should round to 1.00
        XCTAssertEqual(PriceMath.serviceFee(forSubtotal: 19.99), 1.00, accuracy: 0.001)
    }


    func test_search_filtersByTitleAndMinimumRating() async throws {
        let mock = MockSearchRepository()
        mock.searchAllResult = [
            makeProduct(id: 1, title: "Red Shoe", category: "shoes", price: 10, rating: 3.0),
            makeProduct(id: 2, title: "Red Sneaker", category: "shoes", price: 10, rating: 4.5),
            makeProduct(id: 3, title: "Blue Hat", category: "hats", price: 10, rating: 4.5)
        ]
        let sut = SearchUseCase(repository: mock)

        let result = try await sut.search(criteria: SearchCriteria(query: "red", minRating: 4.0))

        XCTAssertEqual(result.products.map(\.id), [2])
    }

    func test_search_sortsByPriceAscending() async throws {
        let mock = MockSearchRepository()
        mock.searchAllResult = [
            makeProduct(id: 1, title: "Item A", category: "x", price: 30, rating: 4),
            makeProduct(id: 2, title: "Item B", category: "x", price: 10, rating: 4)
        ]
        let sut = SearchUseCase(repository: mock)

        let result = try await sut.search(criteria: SearchCriteria(query: "item", sort: .priceAscending))

        XCTAssertEqual(result.products.map(\.id), [2, 1])
    }

    func test_search_categorySelected_usesCompleteCategoryListNotTruncatedGeneralSearch() async throws {
        let mock = MockSearchRepository()
        mock.searchAllResult = [makeProduct(id: 1, title: "Handbag", category: "bags", price: 10, rating: 4)]
        mock.categoryResults["bags"] = [
            makeProduct(id: 1, title: "Handbag One", category: "bags", price: 10, rating: 4),
            makeProduct(id: 2, title: "Handbag Two", category: "bags", price: 10, rating: 4)
        ]
        let category = TripStore.Category(id: "bags", name: "Bags", url: "")
        let sut = SearchUseCase(repository: mock)

        let result = try await sut.search(criteria: SearchCriteria(query: "handbag", category: category))

        XCTAssertEqual(result.products.count, 2, "Category-scoped search must use the complete category list, not the truncated general search batch")
    }

    // MARK: - 3. View-model state paths

    func test_homeViewModel_successfulLoad_transitionsToLoaded() async {
        let mock = MockHomeUseCase()
        mock.productsResult = .success(ProductsResponse(products: [makeProduct(id: 1, stock: 5)], total: 1, skip: 0, limit: 20))
        let sut = HomeViewModel(useCase: mock)

        sut.loadInitial()
        try? await Task.sleep(for: .milliseconds(900)) // clears the view model's minimum-loading-duration floor

        guard case .loaded = sut.state else {
            return XCTFail("Expected .loaded, got \(sut.state)")
        }
    }

    func test_homeViewModel_emptyResponse_transitionsToEmptyState() async {
        let mock = MockHomeUseCase()
        mock.productsResult = .success(ProductsResponse(products: [], total: 0, skip: 0, limit: 20))
        let sut = HomeViewModel(useCase: mock)

        sut.loadInitial()
        try? await Task.sleep(for: .milliseconds(900))

        guard case .empty = sut.state else {
            return XCTFail("Expected .empty, got \(sut.state)")
        }
    }

    func test_searchViewModel_failedSearch_transitionsToErrorState() async {
        let mock = MockSearchUseCase()
        mock.result = .failure(.noConnectivity)
        let sut = SearchViewModel(useCase: mock)

        sut.searchText = "shoe"
        try? await Task.sleep(for: .milliseconds(550))

        guard case .error = sut.state else {
            return XCTFail("Expected .error, got \(sut.state)")
        }
    }

    // MARK: - 4. Repository test using a mock network service

    func test_repository_decodesProductsFromMockedNetworkResponse() async throws {
        let json = """
        {
            "products": [
                { "id": 1, "title": "Mock Product", "category": "mock",
                  "price": 9.99, "rating": 4.2, "stock": 3, "thumbnail": "" }
            ],
            "total": 1, "skip": 0, "limit": 30
        }
        """.data(using: .utf8)!

        let session = MockURLProtocol.makeMockedSession(data: json, statusCode: 200)
        let sut = SearchRepository(networkManager: NetworkManager(session: session))

        let products = try await sut.searchAll(query: "mock")

        XCTAssertEqual(products.first?.title, "Mock Product")
    }

    // MARK: - 5. Obsolete search response cannot overwrite the latest result

    func test_obsoleteSearchResponse_cannotOverwriteNewerResult() async {
        let mock = MockSearchUseCase()
        mock.delayByQuery = [
            "first": .milliseconds(1000),  // long enough to still be in-flight when "second" fires
            "second": .milliseconds(50)
        ]
        mock.resultByQuery = [
            "first": SearchResult(products: [makeProduct(id: 1, title: "First", stock: 5)], availableCategories: []),
            "second": SearchResult(products: [makeProduct(id: 2, title: "Second", stock: 5)], availableCategories: [])
        ]
        let sut = SearchViewModel(useCase: mock)

        sut.searchText = "first"
        try? await Task.sleep(for: .milliseconds(450)) // let "first"'s debounce fire; its request is now in-flight

        sut.searchText = "second"
        try? await Task.sleep(for: .milliseconds(1200)) // past when "second" resolves AND past when "first" would have, uncancelled

        XCTAssertEqual(sut.products.map(\.id), [2], "The slow 'first' response must never overwrite 'second', even after it eventually completes")
    }

    // MARK: - Helpers

    private func makeProduct(
        id: Int,
        title: String = "Item",
        category: String = "test",
        price: Double = 10,
        rating: Double = 4,
        stock: Int = 5
    ) -> Product {
        Product(
            id: id, title: title, description: nil, category: category,
            price: price, discountPercentage: nil, rating: rating, stock: stock,
            brand: nil, thumbnail: "", images: nil
        )
    }
}

// MARK: - Mocks

private final class MockSearchRepository: SearchRepositoryProtocol {
    var searchAllResult: [Product] = []
    var categoryResults: [String: [Product]] = [:]

    func searchAll(query: String) async throws -> [Product] { searchAllResult }
    func fetchByCategory(id: String) async throws -> [Product] { categoryResults[id] ?? [] }
}

private final class MockHomeUseCase: HomeUseCaseProtocol {
    var productsResult: Result<ProductsResponse, NetworkError> = .success(ProductsResponse(products: [], total: 0, skip: 0, limit: 20))

    func loadProducts(limit: Int, skip: Int) async throws -> ProductsResponse { try unwrap(productsResult) }
    func loadProducts(category: String, limit: Int, skip: Int) async throws -> ProductsResponse { try unwrap(productsResult) }
    func loadCategories() async throws -> [TripStore.Category] { [] }
    
    private func unwrap<T>(_ result: Result<T, NetworkError>) throws -> T {
        switch result {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }
}

private final class MockSearchUseCase: SearchUseCaseProtocol {
    var result: Result<SearchResult, NetworkError> = .success(SearchResult(products: [], availableCategories: []))
    var resultByQuery: [String: SearchResult] = [:]
    var delayByQuery: [String: Duration] = [:]

    func search(criteria: SearchCriteria) async throws -> SearchResult {
        if let delay = delayByQuery[criteria.query] {
            try await Task.sleep(for: delay)
        }
        if let queryResult = resultByQuery[criteria.query] {
            return queryResult
        }
        switch result {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }
}

// MARK: - Mock network service (URLProtocol-based — no real network I/O)

final class MockURLProtocol: URLProtocol {
    static var responseData: Data = Data()
    static var responseStatusCode: Int = 200

    static func makeMockedSession(data: Data, statusCode: Int) -> URLSession {
        responseData = data
        responseStatusCode = statusCode
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canInit(with task: URLSessionTask) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let response = HTTPURLResponse(url: request.url!, statusCode: Self.responseStatusCode, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.responseData)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
