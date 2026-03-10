import SwiftUI

enum MainTab: Hashable {
    case home
    case activities
    case profile
}

struct MainTabView: View {
    @State private var selection: MainTab = .home

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Home")
                }
                .tag(MainTab.home)

            ActivitiesRootView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Activities")
                }
                .tag(MainTab.activities)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag(MainTab.profile)
        }
        .tint(.appPrimary)
    }
}

