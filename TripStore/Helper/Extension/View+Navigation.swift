//
//  View+Navigation.swift
//  TripStore
//
//  Created by Mohamed Adel on 17/09/2026.
//

import SwiftUI

extension View {

    func appDestinations() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .product(let product):
                ProductDetailsView(viewModel: ProductDetailsViewModel(product: product))
            case .orderConfirmation(let product, let quantity):
                OrderConfirmationView(product: product, quantity: quantity)
            case .favorites:
                FavoritesView(viewModel: FavoritesViewModel())
            case .orderHistory:
                OrderHistoryView(viewModel: OrderHistoryViewModel())
            }
        }
    }
}
