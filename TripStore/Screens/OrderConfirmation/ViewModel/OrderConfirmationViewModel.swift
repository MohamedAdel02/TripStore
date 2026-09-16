//
//  OrderConfirmationViewModel.swift
//  TripStore
//
//  Created by Mohamed Adel on 16/09/2026.
//

import Foundation
import Combine

@MainActor
final class OrderConfirmationViewModel: ObservableObject {

    let product: Product
    let quantity: Int

    @Published private(set) var isConfirming = false

    private let serviceFeePercentage = 0.05

    init(product: Product, quantity: Int) {
        self.product = product
        self.quantity = quantity
    }

    var subtotal: Double {
        product.price * Double(quantity)
    }

    var serviceFee: Double {
        subtotal * serviceFeePercentage
    }

    var total: Double {
        subtotal + serviceFee
    }

    var formattedSubtotal: String {
        subtotal.formatted(.currency(code: "USD"))
    }

    var formattedServiceFee: String {
        serviceFee.formatted(.currency(code: "USD"))
    }

    var formattedTotal: String {
        total.formatted(.currency(code: "USD"))
    }

    func confirmOrder() async {
        guard !isConfirming else { return }

        isConfirming = true

        // Future:
        // 1. Create Order
        // 2. Persist it locally
        // 3. Clear/reset the order flow

        // Temporary delay to simulate confirmation.
        try? await Task.sleep(for: .milliseconds(500))

        isConfirming = false
    }
}
