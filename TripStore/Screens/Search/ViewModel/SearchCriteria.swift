//
//  SearchCriteria.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation

struct SearchCriteria: Equatable {
    var query: String = ""
    var category: Category?
    var minRating: Double = 0
    var sort: SortOption = .none

    var isDefault: Bool {
        self == SearchCriteria()
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case none
    case priceAscending
    case priceDescending
    case ratingAscending
    case ratingDescending

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "Default"
        case .priceAscending: return "Price: Low to High"
        case .priceDescending: return "Price: High to Low"
        case .ratingAscending: return "Rating: Low to High"
        case .ratingDescending: return "Rating: High to Low"
        }
    }

    var iconName: String {
        switch self {
        case .none: return "arrow.up.arrow.down"
        case .priceAscending: return "arrow.up"
        case .priceDescending: return "arrow.down"
        case .ratingAscending: return "star"
        case .ratingDescending: return "star.fill"
        }
    }
}
