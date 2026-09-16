//
//  OrderHistoryView.swift
//  TripStore
//
//  Created by Mohamed Adel on 16/09/2026.
//

import SwiftUI

struct OrderHistoryView: View {

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {

                    // Future:
                    // ForEach(orders) { order in
                    //     OrderRow(order: order)
                    // }

                    emptyState
                }
                .padding()
            }
        }
        .navigationTitle("Order History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 40))
                .foregroundStyle(.customGray.opacity(0.6))

            Text("No Orders Yet")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Your confirmed orders will appear here.")
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
        OrderHistoryView()
    }
}
