//
//  NetworkManager.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation

class NetworkManager {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func send<T: Decodable>(_ request: HTTPRequest, as type: T.Type) async throws -> T {

        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        let data: Data
        let response: URLResponse

        do {
            try Task.checkCancellation()
            (data, response) = try await session.data(for: urlRequest)
        } catch is CancellationError {
            throw NetworkError.cancelled
        } catch let error as URLError {
            switch error.code {
            case .cancelled:
                throw NetworkError.cancelled
            case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                throw NetworkError.noConnectivity
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown(error.localizedDescription)
            }
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown("Non-HTTP response")
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        case 400...499:
            throw NetworkError.client(statusCode: httpResponse.statusCode)
        case 500...599:
            throw NetworkError.server(statusCode: httpResponse.statusCode)
        default:
            throw NetworkError.unknown("Unexpected status code \(httpResponse.statusCode)")
        }

        try Task.checkCancellation()

        do {
            return try decoder.decode(T.self, from: data)
        } catch is CancellationError {
            throw NetworkError.cancelled
        } catch {
            throw NetworkError.decoding(String(describing: error))
        }
    }
}
