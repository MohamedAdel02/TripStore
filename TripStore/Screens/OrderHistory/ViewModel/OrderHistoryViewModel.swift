//
//  OrderHistoryViewModel.swift
//  TripStore
//
//  Created by Mohamed Adel on 17/09/2026.
//

import Foundation
import Combine

@MainActor
class OrderHistoryViewModel: ObservableObject {

    @Published var orders: [Order] = []

    private let repository = OrderHistoryRepository()

    var isEmpty: Bool {
        orders.isEmpty
    }

    func load() {
        orders = repository.fetchAll()
    }
}
