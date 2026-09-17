//
//  AppRoute.swift
//  TripStore
//
//  Created by Mohamed Adel on 17/09/2026.
//

import Foundation

enum AppRoute: Hashable {
    case product(Product)
    case orderConfirmation(Product, Int)
    case favorites
    case orderHistory
}
