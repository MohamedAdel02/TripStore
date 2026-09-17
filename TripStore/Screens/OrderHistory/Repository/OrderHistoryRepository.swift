//
//  OrderHistoryRepository.swift
//  TripStore
//
//  Created by Mohamed Adel on 17/09/2026.
//

import Foundation
import RealmSwift

class OrderHistoryRepository {

    func save(_ order: Order) throws {
        let realm = try realm()
        try realm.write {
            realm.add(OrderObject(order), update: .error)
        }
    }

    func fetchAll() -> [Order] {
        guard let realm = try? realm() else { return [] }
        return realm.objects(OrderObject.self)
            .sorted(byKeyPath: "createdAt", ascending: false)
            .map(\.asOrder)
    }

    func count() -> Int {
        (try? realm())?.objects(OrderObject.self).count ?? 0
    }

    private func realm() throws -> Realm {
        try Realm(configuration: Realm.Configuration(
            schemaVersion: 1,
            deleteRealmIfMigrationNeeded: true
        ))
    }
}
