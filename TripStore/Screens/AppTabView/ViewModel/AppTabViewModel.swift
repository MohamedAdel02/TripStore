//
//  AppTabViewModel.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class AppTabViewModel: ObservableObject {

    @Published var selectedTab: AppTab = .home
    @Published var homePath: [AppRoute] = []
    @Published var profilePath: [AppRoute] = []

    func returnToHome() {
        homePath.removeAll()
        profilePath.removeAll()
        selectedTab = .home
    }
}

struct ReturnToHomeAction {
    let action: () -> Void

    func callAsFunction() {
        action()
    }
}

extension EnvironmentValues {
    @Entry var returnToHome = ReturnToHomeAction(action: {})
}
