//
//  View+Extension.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import SwiftUI
import SkeletonUI

extension View {

    func addSkelton(_ isLoading: Bool = true, shape: ShapeType = .rectangle) -> some View {
        self.skeleton(with: isLoading,
                      animation: .linear(),
                      appearance: .gradient(color: .white.opacity(0.25), background: .white.opacity(0.08)),
                      shape: shape)
    }
    
}
