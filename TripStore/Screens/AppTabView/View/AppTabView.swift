//
//  AppTabView.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import SwiftUI


struct AppTabView: View {

    @StateObject private var viewModel = AppTabViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            
            NavigationStack(path: $viewModel.homePath) {
                HomeView(viewModel: HomeViewModel())
                    .appDestinations()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(AppTab.home)

            NavigationStack {
                //SearchView(viewModel: SearchViewModel())
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(AppTab.search)

            NavigationStack(path: $viewModel.profilePath) {
                ProfileView(viewModel: ProfileViewModel())
                    .appDestinations()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(AppTab.profile)
        }
        .tint(Color.customTeal)
        .withToast()
        .environment(\.returnToHome, ReturnToHomeAction(action: {
            viewModel.returnToHome()
        }))
    }
}

#Preview {
    AppTabView()
}
