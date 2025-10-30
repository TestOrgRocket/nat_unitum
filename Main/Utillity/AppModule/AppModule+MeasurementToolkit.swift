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
            Color(red: 4.0 / 255.0, green: 113.0 / 255.0, blue: 143.0 / 255.0)
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
