//
//  FavoritesView.swift
//  TripStore
//
//  Created by Mohamed Adel on 16/09/2026.
//

import SwiftUI

struct FavoritesView: View {

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {

                    // Future:
                    // ForEach(favorites) { product in
                    //     ProductRow(product: product)
                    // }

                    emptyState
                }
                .padding()
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.system(size: 40))
                .foregroundStyle(.customGray.opacity(0.6))

            Text("No Favorites Yet")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Products you favorite will appear here.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.customGray.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 120)
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
    }
}
