//
//  ChipLabel.swift
//  TripStore
//
//  Created by Mohamed Adel on 17/09/2026.
//

import SwiftUI

struct ChipLabel: View {

    let title: String
    let isActive: Bool
    var fullWidth: Bool = false

    var body: some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(isActive ? .semibold : .regular)
            .multilineTextAlignment(.center)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isActive ? Color.customTeal : Color.customGray.opacity(0.15))
            )
            .foregroundStyle(isActive ? .white : .customGray)
    }
}

