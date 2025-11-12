import SwiftUI
import UIKit

/// Root namespace for plug-and-play utility modules that can be embedded from UIKit.
enum AppModule {
    /// Measurement & Utility toolkit root controller that can be used as the application window's root.
    final class MeasurementToolkit: UIHostingController<MeasurementToolkitContainerView> {
        convenience init() {
            self.init(state: .shared)
        }

        init(state: MeasurementToolkitState) {
            super.init(rootView: MeasurementToolkitContainerView(state: state))
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            // Ensure hosting controller's view is transparent so SwiftUI backgrounds
            // that ignore the safe area can show through under the status bar/notch.
            view.backgroundColor = .clear

            // Scope UITableView appearance to this hosting controller only so other
            // parts of the app are not affected.
            UITableView.appearance(whenContainedInInstancesOf: [AppModule.MeasurementToolkit.self]).backgroundColor = .clear
            UITableViewCell.appearance(whenContainedInInstancesOf: [AppModule.MeasurementToolkit.self]).backgroundColor = .clear
            UITableViewHeaderFooterView.appearance(whenContainedInInstancesOf: [AppModule.MeasurementToolkit.self]).tintColor = .clear
            UITableView.appearance(whenContainedInInstancesOf: [AppModule.MeasurementToolkit.self]).separatorStyle = .none
        }

        @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            let state = MeasurementToolkitState.shared
            super.init(coder: aDecoder, rootView: MeasurementToolkitContainerView(state: state))
        }
    }
}

struct MeasurementToolkitContainerView: View {
    @StateObject private var state: MeasurementToolkitState

    init(state: MeasurementToolkitState) {
        _state = StateObject(wrappedValue: state)
    }

    var body: some View {
        MeasurementToolkitRootView()
            .environmentObject(state)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                            Color(red: 4.0 / 255.0, green: 113.0 / 255.0, blue: 143.0 / 255.0),
                        Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0),
                        Color(red: 72.0 / 255.0, green: 202.0 / 255.0, blue: 228.0 / 255.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
        )
    }
}

struct MeasurementToolkitWrapperView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AppModule.MeasurementToolkit {
        AppModule.MeasurementToolkit()
    }

    func updateUIViewController(_ uiViewController: AppModule.MeasurementToolkit, context: Context) {}
}
