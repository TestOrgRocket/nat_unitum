import SwiftUI

struct MeasurementToolkitRootView: View {
    @EnvironmentObject private var state: MeasurementToolkitState

    var body: some View {
        TabView {
            if #available(iOS 16.0, *) {
                NavigationStack { ConverterRootView() }
                    .tabItem { Label("Converter", systemImage: "arrow.triangle.2.circlepath") }
            } else {
                // Fallback on earlier versions
            }

            if #available(iOS 16.0, *) {
                NavigationStack { FavoritesHistoryView() }
                    .tabItem { Label("Favorites", systemImage: "star.circle") }
            } else {
                // Fallback on earlier versions
            }

            if #available(iOS 16.0, *) {
                NavigationStack { CountersRootView() }
                    .tabItem { Label("Counters", systemImage: "number") }
            } else {
                // Fallback on earlier versions
            }

            if #available(iOS 16.0, *) {
                NavigationStack { CustomUnitsRootView() }
                    .tabItem { Label("Units", systemImage: "slider.horizontal.3") }
            } else {
                // Fallback on earlier versions
            }

            if #available(iOS 16.0, *) {
                NavigationStack { ReferenceRootView() }
                    .tabItem { Label("Reference", systemImage: "book") }
            } else {
                // Fallback on earlier versions
            }

            if #available(iOS 16.0, *) {
                NavigationStack { SettingsRootView() }
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            } else {
                // Fallback on earlier versions
            }
            
            PrivacyPolicyView()
            .tabItem {
                Label("Privacy Policy", systemImage: "lock.shield")
            }
        }
    }
}


struct PrivacyPolicyView: View {
    var body: some View {
        Color.clear // ничего не показываем
            .onAppear {
                if let url = URL(string: "https://unitumapp.com/privacy-policy.html") {
                    UIApplication.shared.open(url)
                }
            }
    }
}
