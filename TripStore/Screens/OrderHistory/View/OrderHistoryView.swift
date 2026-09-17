//
//  OrderHistoryView.swift
//  TripStore
//
//  Created by Mohamed Adel on 16/09/2026.
//

import SwiftUI
import Kingfisher

struct OrderHistoryView: View {

    @StateObject private var viewModel: OrderHistoryViewModel

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    init(viewModel: OrderHistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackground()

            if viewModel.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.orders) { order in
                            orderRow(order)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Order History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            viewModel.load()
        }
    }

    private func orderRow(_ order: Order) -> some View {
        HStack(alignment: .top, spacing: 14) {
            thumbnail(for: order)

            VStack(alignment: .leading, spacing: 6) {
                Text(order.productTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(order.productCategory.capitalized)
                    .font(.caption)
                    .foregroundStyle(.customGray.opacity(0.8))

                Text("Qty \(order.quantity) · \(order.total.formatted(.currency(code: "USD")))")
                    .font(.subheadline)
                    .foregroundStyle(.white)

                Text(dateFormatter.string(from: order.createdAt))
                    .font(.caption2)
                    .foregroundStyle(.customGray.opacity(0.7))

                Text("ID \(shortID(order.id))")
                    .font(.caption2)
                    .foregroundStyle(.customGray.opacity(0.55))
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Order for \(order.productTitle), quantity \(order.quantity), total \(order.total.formatted(.currency(code: "USD"))), \(dateFormatter.string(from: order.createdAt))"
        )
    }

    private func thumbnail(for order: Order) -> some View {
        ZStack {
            Color.white.opacity(0.06)

            if let url = URL(string: order.productThumbnail) {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(6)
            } else {
                Image(systemName: "bag")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func shortID(_ id: String) -> String {
        String(id.prefix(8)).uppercased()
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    NavigationStack {
        OrderHistoryView(viewModel: OrderHistoryViewModel())
    }
}
