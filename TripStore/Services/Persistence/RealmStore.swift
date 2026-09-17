//
//  RealmStore.swift
//  TripStore
//
//  Created by Mohamed Adel on 17/09/2026.
//

import Foundation
import RealmSwift

enum RealmStore {

    static func realm() throws -> Realm {
        try Realm(configuration: configuration)
    }

    private static let configuration: Realm.Configuration = {
        var config = Realm.Configuration(
            schemaVersion: 1,
            deleteRealmIfMigrationNeeded: true
        )
        if NSClassFromString("XCTestCase") != nil {
            config.inMemoryIdentifier = "TripStore.Tests"
        }
        return config
    }()
}
