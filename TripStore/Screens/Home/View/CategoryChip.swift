//
//  CategoryChip.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import SwiftUI
import SkeletonUI

struct CategoryChip: View {

    let title: String
    let isSelected: Bool
    let isLoading: Bool
    let action: () -> Void

    init(title: String, isSelected: Bool, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(isLoading ? "Category" : title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundStyle(
                    isSelected ? .white : .customGray
                )
                .background(
                    Capsule()
                        .fill(isSelected ? Color.customTeal : Color.customGray.opacity(0.15))
                )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .accessibilityHidden(isLoading)
        .accessibilityAddTraits(isLoading ? [] : .isSelected)
    }
}
