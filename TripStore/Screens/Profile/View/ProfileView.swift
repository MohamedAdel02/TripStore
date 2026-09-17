//
//  ProfileView.swift
//  TripStore
//
//  Created by Mohamed Adel on 16/09/2026.
//

import SwiftUI

struct ProfileView: View {

    @StateObject private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    header
                    menuSection
                }
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            viewModel.load()
        }
    }


    private var header: some View {
        VStack(spacing: 12) {

            Circle()
                .fill(.customGray.opacity(0.15))
                .frame(width: 90, height: 90)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.customGray.opacity(0.7))
                }

            VStack(spacing: 4) {
                Text("Guest")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Text("Welcome to Trip Store")
                    .font(.subheadline)
                    .foregroundStyle(.customGray.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }


    private var menuSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("My Store")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 0) {

                NavigationLink(value: AppRoute.favorites) {
                    profileRow(
                        icon: "heart.fill",
                        title: "Favorites",
                        badge: viewModel.favoriteCount
                    )
                }
                .buttonStyle(.plain)

                divider

                NavigationLink(value: AppRoute.orderHistory) {
                    profileRow(
                        icon: "clock.arrow.circlepath",
                        title: "Order History",
                        badge: viewModel.orderCount
                    )
                }
                .buttonStyle(.plain)
            }
            .background(.customGray.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal)
    }


    private func profileRow(icon: String, title: String, badge: Int) -> some View {
        HStack(spacing: 14) {

            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 24)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white)

            Spacer()

            if badge > 0 {
                Text("\(badge)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.8), in: Capsule())
                    .accessibilityLabel("\(badge) items")
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.customGray.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .contentShape(Rectangle())
    }

    private var divider: some View {
        Divider()
            .padding(.leading, 54)
            .background(.white.opacity(0.08))
    }
}
