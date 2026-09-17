//
//  ProfileViewModel.swift
//  TripStore
//
//  Created by Mohamed Adel on 16/09/2026.
//

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {

    @Published var favoriteCount = 0
    @Published var orderCount = 0

    private let favoritesRepository = FavoritesRepository()
    private let ordersRepository = OrderHistoryRepository()

    func load() {
        favoriteCount = favoritesRepository.count()
        orderCount = ordersRepository.count()
    }
}
