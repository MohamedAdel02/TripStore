//
//  ProfileViewModel.swift
//  TripStore
//
//  Created by Mohamed Adel on 16/09/2026.
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var favoriteCount = 0
    @Published var orderCount = 0

    func load() {

    }
}
