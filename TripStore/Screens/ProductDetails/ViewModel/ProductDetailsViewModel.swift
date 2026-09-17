//
//  ProductDetailsViewModel.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation
import Combine

@MainActor
class ProductDetailsViewModel: ObservableObject {

    let product: Product

    @Published var quantity: Int = 1
    @Published var isFavorite = false

    private let favoritesRepository = FavoritesRepository()

    init(product: Product) {
        self.product = product
    }

    var galleryURLs: [URL] {
        let sources = (product.images?.isEmpty == false)
            ? (product.images ?? [product.thumbnail])
            : [product.thumbnail]

        return sources.compactMap(URL.init(string:))
    }

    var isOutOfStock: Bool {
        product.stock <= 0
    }

    var maxQuantity: Int {
        product.stock
    }

    var canIncrement: Bool {
        !isOutOfStock && quantity < maxQuantity
    }

    var canDecrement: Bool {
        !isOutOfStock && quantity > 1
    }

    var canOrder: Bool {
        !isOutOfStock && (1...maxQuantity).contains(quantity)
    }

    var totalPrice: Double {
        PriceMath.subtotal(unitPrice: product.price, quantity: quantity)
    }

    var formattedTotalPrice: String {
        totalPrice.formatted(.currency(code: "USD"))
    }

    func refreshFavoriteState() {
        isFavorite = favoritesRepository.isFavorite(product.id)
    }

    func toggleFavorite() {
        do {
            isFavorite = try favoritesRepository.toggle(product)
        } catch {
            refreshFavoriteState()
        }
    }

    func increment() {
        guard canIncrement else { return }
        quantity += 1
    }

    func decrement() {
        guard canDecrement else { return }
        quantity -= 1
    }
}
