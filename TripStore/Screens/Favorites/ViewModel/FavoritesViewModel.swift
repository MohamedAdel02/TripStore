//
//  FavoritesViewModel.swift
//  TripStore
//
//  Created by Mohamed Adel on 17/09/2026.
//

import Foundation
import Combine

@MainActor
class FavoritesViewModel: ObservableObject {

    @Published var favorites: [Product] = []

    private let repository = FavoritesRepository()

    var isEmpty: Bool {
        favorites.isEmpty
    }

    func load() {
        favorites = repository.fetchAll()
    }

    func remove(_ product: Product) {
        do {
            try repository.remove(productId: product.id)
        } catch {}
        load()
    }
}
