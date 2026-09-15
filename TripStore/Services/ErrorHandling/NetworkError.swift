//
//  NetworkError.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation

enum NetworkError: LocalizedError {

    case invalidURL
    case noConnectivity
    case timeout
    case cancelled
    case unauthorized
    case server(statusCode: Int)
    case client(statusCode: Int)
    case decoding(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "The request URL is invalid.")
        case .noConnectivity:
            return String(localized: "No internet connection. Please check your network.")
        case .timeout:
            return String(localized: "The request timed out. Please try again.")
        case .cancelled:
            return String(localized: "The request was cancelled.")
        case .unauthorized:
            return String(localized: "You are not authorized to perform this action.")
        case .server(let statusCode):
            return String(localized: "Server error (\(statusCode)). Please try again later.")
        case .client(let statusCode):
            return String(localized: "Request error (\(statusCode)). Please check and try again.")
        case .decoding(let message):
            return String(localized: "Failed to process the response: \(message)")
        case .unknown(let message):
            return String(localized: "Something went wrong: \(message)")
        }
    }

    var isRetryable: Bool {
        switch self {
        case .noConnectivity, .timeout, .server, .unknown:
            return true
        case .invalidURL, .cancelled, .unauthorized, .client, .decoding:
            return false
        }
    }
}
