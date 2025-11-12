
import SwiftUI

struct MeasurementToolkitRootView: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    @State private var selectedTab: Tab = .converter

    enum Tab: Int, CaseIterable {
        case converter, favorites, counters, units, reference, settings

        var title: String {
            switch self {
            case .converter: return "Converter"
            case .favorites: return "Favorites"
            case .counters: return "Counters"
            case .units: return "Units"
            case .reference: return "Reference"
            case .settings: return "Settings"
            }
        }
        var systemImage: String {
            switch self {
            case .converter: return "arrow.triangle.2.circlepath"
            case .favorites: return "star.circle"
            case .counters: return "number"
            case .units: return "slider.horizontal.3"
            case .reference: return "book"
            case .settings: return "gearshape"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .converter:
                    if #available(iOS 16.0, *) {
                        NavigationStack { ConverterRootView() }
                    }
                case .favorites:
                    if #available(iOS 16.0, *) {
                        NavigationStack { FavoritesHistoryView() }
                    }
                case .counters:
                    if #available(iOS 16.0, *) {
                        NavigationStack { CountersRootView() }
                    }
                case .units:
                    if #available(iOS 16.0, *) {
                        NavigationStack { CustomUnitsRootView() }
                    }
                case .reference:
                    if #available(iOS 16.0, *) {
                        NavigationStack { ReferenceRootView() }
                    }
                case .settings:
                    if #available(iOS 16.0, *) {
                        NavigationStack { SettingsRootView() }
                    }
                // Privacy policy теперь только в настройках
                }
            }
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

private struct CustomTabBar: View {
    @Binding var selectedTab: MeasurementToolkitRootView.Tab

    let gradientColors = [
        Color(red: 4.0 / 255.0, green: 113.0 / 255.0, blue: 143.0 / 255.0),
        Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0),
        Color(red: 72.0 / 255.0, green: 202.0 / 255.0, blue: 228.0 / 255.0)
    ]

    var body: some View {
        HStack {
            ForEach(MeasurementToolkitRootView.Tab.allCases, id: \ .self) { tab in
                Spacer()
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 2) {
                        ZStack {
                            if selectedTab == tab {
                                RadialGradient(
                                    gradient: Gradient(colors: gradientColors),
                                    center: .center,
                                    startRadius: 2,
                                    endRadius: 22
                                )
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                                .shadow(color: gradientColors[0].opacity(0.18), radius: 6, x: 0, y: 2)
                                Image(systemName: tab.systemImage)
                                    .foregroundColor(.white)
                                    .font(.system(size: 22, weight: .semibold))
                            } else {
                                Circle()
                                    .fill(Color(red: 4.0 / 255.0, green: 113.0 / 255.0, blue: 143.0 / 255.0))
                                    .frame(width: 36, height: 36)
                                    .opacity(0.12)
                                Image(systemName: tab.systemImage)
                                    .foregroundColor(Color(red: 4.0 / 255.0, green: 113.0 / 255.0, blue: 143.0 / 255.0))
                                    .font(.system(size: 22, weight: .regular))
                            }
                        }
                        Text(tab.title)
                            .font(.caption2)
                            .foregroundColor(selectedTab == tab ? Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0) : Color(red: 4.0 / 255.0, green: 113.0 / 255.0, blue: 143.0 / 255.0).opacity(0.7))
                            .padding(.top, 1)
                    }
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: -2)
        )
    }
}


