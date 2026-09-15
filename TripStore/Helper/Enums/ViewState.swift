//
//  ViewState.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation

enum ViewState {
    case loading
    case loaded
    case empty
    case error(NetworkError)
}
