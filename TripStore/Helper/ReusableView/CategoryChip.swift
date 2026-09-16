//
//  CategoryChip.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import SwiftUI

struct CategoryChip: View {

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ChipLabel(title: title, isActive: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
