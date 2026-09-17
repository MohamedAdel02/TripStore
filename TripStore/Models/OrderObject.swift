//
//  OrderObject.swift
//  TripStore
//
//  Created by Mohamed Adel on 17/09/2026.
//

import Foundation
import RealmSwift

class OrderObject: Object {
    @Persisted(primaryKey: true) var id = ""
    @Persisted var createdAt = Date()
    @Persisted var productId = 0
    @Persisted var productTitle = ""
    @Persisted var productThumbnail = ""
    @Persisted var productCategory = ""
    @Persisted var unitPrice = 0.0
    @Persisted var quantity = 0
    @Persisted var subtotal = 0.0
    @Persisted var serviceFee = 0.0
    @Persisted var total = 0.0

    convenience init(_ order: Order) {
        self.init()
        id = order.id
        createdAt = order.createdAt
        productId = order.productId
        productTitle = order.productTitle
        productThumbnail = order.productThumbnail
        productCategory = order.productCategory
        unitPrice = order.unitPrice
        quantity = order.quantity
        subtotal = order.subtotal
        serviceFee = order.serviceFee
        total = order.total
    }

    var asOrder: Order {
        Order(
            id: id,
            createdAt: createdAt,
            productId: productId,
            productTitle: productTitle.isEmpty ? "Unknown product" : productTitle,
            productThumbnail: productThumbnail,
            productCategory: productCategory.isEmpty ? "uncategorized" : productCategory,
            unitPrice: unitPrice,
            quantity: quantity,
            subtotal: subtotal,
            serviceFee: serviceFee,
            total: total
        )
    }
}
