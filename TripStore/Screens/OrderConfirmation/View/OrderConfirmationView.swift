//
//  OrderConfirmationView.swift
//  TripStore
//
//  Created by Mohamed Adel on 16/09/2026.
//

import SwiftUI
import Kingfisher

struct OrderConfirmationView: View {

    @Environment(\.showToast) private var showToast
    @Environment(\.returnToHome) private var returnToHome
    @StateObject private var viewModel: OrderConfirmationViewModel

    init(product: Product, quantity: Int) {
        _viewModel = StateObject(wrappedValue: OrderConfirmationViewModel(product: product,quantity: quantity)
        )
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    productSection

                    Divider()
                        .background(.customGray.opacity(0.8))

                    summarySection

                    if let confirmationError = viewModel.confirmationError {
                        Text(confirmationError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    confirmationButton
                }
                .padding()
            }
        }
        .navigationTitle("Confirm Order")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onChange(of: viewModel.didConfirm) { didConfirm in
            guard didConfirm else { return }
            showToast(.success("Order placed successfully"), placement: .top)
            returnToHome()
        }
    }

    // MARK: - Product

    private var productSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Order Summary")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            HStack(spacing: 16) {

                productImage

                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.product.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Text(viewModel.product.category.capitalized)
                        .font(.caption)
                        .foregroundStyle(.customGray.opacity(0.8))

                    Text("Quantity: \(viewModel.quantity)")
                        .font(.subheadline)
                        .foregroundStyle(.customGray.opacity(0.8))

                    Text(viewModel.product.price.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }

                Spacer()
            }
            .padding()
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )
        }
    }

    private var productImage: some View {
        ZStack {
            Color.white.opacity(0.06)

            if let url = viewModel.productImageURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(8)
            } else {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
        )
    }

    // MARK: - Summary

    private var summarySection: some View {
        VStack(spacing: 16) {

            summaryRow(
                title: "Subtotal",
                value: viewModel.formattedSubtotal
            )

            summaryRow(
                title: "Service Fee (5%)",
                value: viewModel.formattedServiceFee
            )

            Divider()
                .background(.customGray.opacity(0.8))

            HStack {
                Text("Total")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Text(viewModel.formattedTotal)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
    }

    private func summaryRow(title: String,value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.customGray.opacity(0.8))

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }

    // MARK: - Confirmation

    private var confirmationButton: some View {
        Button {
            Task {
                await viewModel.confirmOrder()
            }
        } label: {
            HStack(spacing: 8) {
                if viewModel.isConfirming {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(0.9)
                }

                Text(
                    viewModel.isConfirming
                    ? "Confirming..."
                    : viewModel.didConfirm
                    ? "Order Confirmed"
                    : "Confirm Order"
                )
                .font(.headline)
                .bold()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundStyle(.white)
            .background(
                (viewModel.isConfirming || viewModel.didConfirm)
                ? Color.accentColor.opacity(0.6)
                : Color.accentColor
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isConfirming || viewModel.didConfirm)
        .accessibilityLabel("Confirm order")
    }
}

// MARK: - Helpers

private extension OrderConfirmationViewModel {

    var productImageURL: URL? {
        if let images = product.images,
           let firstImage = images.first,
           let url = URL(string: firstImage) {
            return url
        }

        return URL(string: product.thumbnail)
    }
}
