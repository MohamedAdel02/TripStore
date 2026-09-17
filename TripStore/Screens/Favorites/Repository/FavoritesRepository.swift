//
//  FavoritesRepository.swift
//  TripStore
//
//  Created by Mohamed Adel on 17/09/2026.
//

import Foundation
import RealmSwift

class FavoritesRepository {

    func isFavorite(_ productId: Int) -> Bool {
        (try? realm())?.object(ofType: FavoriteObject.self, forPrimaryKey: productId) != nil
    }

    func fetchAll() -> [Product] {
        guard let realm = try? realm() else { return [] }
        return realm.objects(FavoriteObject.self)
            .sorted(byKeyPath: "createdAt", ascending: false)
            .map(\.asProduct)
    }

    func count() -> Int {
        (try? realm())?.objects(FavoriteObject.self).count ?? 0
    }

    @discardableResult
    func toggle(_ product: Product) throws -> Bool {
        if isFavorite(product.id) {
            try remove(productId: product.id)
            return false
        }
        try add(product)
        return true
    }

    func remove(productId: Int) throws {
        let realm = try realm()
        guard let object = realm.object(ofType: FavoriteObject.self, forPrimaryKey: productId) else { return }
        try realm.write { realm.delete(object) }
    }

    private func add(_ product: Product) throws {
        let realm = try realm()
        try realm.write {
            realm.add(FavoriteObject(product), update: .modified)
        }
    }

    private func realm() throws -> Realm {
        try Realm(configuration: Realm.Configuration(
            schemaVersion: 1,
            deleteRealmIfMigrationNeeded: true
        ))
    }
}
