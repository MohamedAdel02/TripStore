//
//  OrderConfirmationViewModel.swift
//  TripStore
//
//  Created by Mohamed Adel on 16/09/2026.
//

import Foundation
import Combine

@MainActor
class OrderConfirmationViewModel: ObservableObject {

    let product: Product
    let quantity: Int

    @Published var isConfirming = false
    @Published var didConfirm = false
    @Published var confirmationError: String?

    private let repository = OrderHistoryRepository()

    init(product: Product, quantity: Int) {
        self.product = product
        self.quantity = quantity
    }

    var subtotal: Double {
        PriceMath.subtotal(unitPrice: product.price, quantity: quantity)
    }

    var serviceFee: Double {
        PriceMath.serviceFee(forSubtotal: subtotal)
    }

    var total: Double {
        PriceMath.total(subtotal: subtotal, serviceFee: serviceFee)
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
        guard !isConfirming, !didConfirm else { return }

        isConfirming = true
        confirmationError = nil

        let order = Order(
            id: UUID().uuidString,
            createdAt: Date(),
            productId: product.id,
            productTitle: product.title,
            productThumbnail: product.thumbnail,
            productCategory: product.category,
            unitPrice: product.price,
            quantity: quantity,
            subtotal: subtotal,
            serviceFee: serviceFee,
            total: total
        )

        do {
            try await Task.sleep(for: .seconds(1.5))
            try repository.save(order)
            didConfirm = true
        } catch is CancellationError {
            // Ignore cancelled confirmation work.
        } catch {
            confirmationError = "Could not save your order. Please try again."
        }

        isConfirming = false
    }
}
