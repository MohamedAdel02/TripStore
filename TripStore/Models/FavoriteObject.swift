//
//  FavoriteObject.swift
//  TripStore
//
//  Created by Mohamed Adel on 17/09/2026.
//

import Foundation
import RealmSwift

nonisolated class FavoriteObject: Object {
    @Persisted(primaryKey: true) var productId = 0
    @Persisted var title = ""
    @Persisted var productDescription: String?
    @Persisted var category = ""
    @Persisted var price = 0.0
    @Persisted var discountPercentage: Double?
    @Persisted var rating = 0.0
    @Persisted var stock = 0
    @Persisted var brand: String?
    @Persisted var thumbnail = ""
    @Persisted var images = List<String>()
    @Persisted var createdAt = Date()

    convenience init(_ product: Product) {
        self.init()
        productId = product.id
        title = product.title
        productDescription = product.description
        category = product.category
        price = product.price
        discountPercentage = product.discountPercentage
        rating = product.rating
        stock = product.stock
        brand = product.brand
        thumbnail = product.thumbnail
        images.append(objectsIn: product.images ?? [])
    }

    var asProduct: Product {
        Product(
            id: productId,
            title: title.isEmpty ? "Unknown product" : title,
            description: productDescription,
            category: category.isEmpty ? "uncategorized" : category,
            price: price,
            discountPercentage: discountPercentage,
            rating: rating,
            stock: stock,
            brand: brand,
            thumbnail: thumbnail,
            images: images.isEmpty ? nil : Array(images)
        )
    }
}
