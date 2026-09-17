//
//  Order.swift
//  TripStore
//
//  Created by Mohamed Adel on 17/09/2026.
//

import Foundation

struct Order: Identifiable, Equatable, Hashable {
    let id: String
    let createdAt: Date
    let productId: Int
    let productTitle: String
    let productThumbnail: String
    let productCategory: String
    let unitPrice: Double
    let quantity: Int
    let subtotal: Double
    let serviceFee: Double
    let total: Double
}

enum PriceMath {
    static let serviceFeePercentage = 0.05

    static func rounded(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }

    static func subtotal(unitPrice: Double, quantity: Int) -> Double {
        rounded(unitPrice * Double(quantity))
    }

    static func serviceFee(forSubtotal subtotal: Double) -> Double {
        rounded(subtotal * serviceFeePercentage)
    }

    static func total(subtotal: Double, serviceFee: Double) -> Double {
        rounded(subtotal + serviceFee)
    }
}
