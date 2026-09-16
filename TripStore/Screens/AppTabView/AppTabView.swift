//
//  AppTabView.swift
//  TripStore
//
//  Created by Mohamed Adel on 15/09/2026.
//

import SwiftUI
import SwiftData

struct AppTabView: View {
    
    @State private var viewModel = AppTabViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(viewModel: HomeViewModel())
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                //SearchView(viewModel: SearchViewModel())
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                ProfileView(viewModel: ProfileViewModel())
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
        .tint(Color.customTeal)
    }
    
}

#Preview {
    AppTabView()
}


