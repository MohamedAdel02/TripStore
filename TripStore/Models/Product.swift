//
//  Product.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation

struct ProductsResponse: Codable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}

struct Product: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let title: String
    let description: String?
    let category: String
    let price: Double
    let discountPercentage: Double?
    let rating: Double
    let stock: Int
    let brand: String?
    let thumbnail: String
    let images: [String]?
}
