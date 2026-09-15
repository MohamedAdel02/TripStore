//
//  Category.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation

struct Category: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let url: String
 
    enum CodingKeys: String, CodingKey {
        case id = "slug"
        case name
        case url
    }
}
