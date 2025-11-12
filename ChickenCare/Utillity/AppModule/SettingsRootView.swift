import SwiftUI

struct SettingsRootView: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    @State private var precision: Double = 2

    var body: some View {
        ZStack {
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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Precision
                    SectionHeader(title: "Precision")
                    HStack {
                        Text("Decimal places: \(Int(precision))")
                            .foregroundColor(.primary)
                        Spacer()
                        Stepper("", value: $precision, in: 0...6, step: 1)
                            .labelsHidden()
                            .onChange(of: precision) { newValue in
                                state.updatePrecision(Int(newValue))
                            }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.panelBackground))
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)

                    // Format
                    SectionHeader(title: "Format")
                    HStack {
                        Text("Use grouping separators")
                            .foregroundColor(.primary)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { state.settings.groupingSeparatorEnabled },
                            set: { newValue in state.settings.groupingSeparatorEnabled = newValue }
                        ))
                        .labelsHidden()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.panelBackground))
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)

                    // Defaults
                    SectionHeader(title: "Defaults")
                    VStack(spacing: 12) {
                        ForEach(MeasurementCategory.allCases, id: \.id) { category in
                            NavigationLink(destination: DefaultUnitPicker(category: category)) {
                                HStack {
                                    Text(category.title)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.gray)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.panelBackground))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }

                    // Data
                    SectionHeader(title: "Data")
                    HStack {
                        Button("Clear history") { state.history.removeAll() }
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.panelBackground))

                    // Links
                    SectionHeader(title: "Support")
                    HStack {
                        Button(action: {
                            if let url = URL(string: "https://unitumapp.com/privacy-policy.html") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.shield")
                                    .foregroundColor(Color(red: 4.0 / 255.0, green: 113.0 / 255.0, blue: 143.0 / 255.0))
                                Text("Privacy Policy")
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.panelBackground))
                        }
                        Spacer()
                    }
                }
                .padding()
            }
        }
        .onAppear {
            precision = Double(state.settings.precision)
        }
        .gradientNavigationTitle("Settings")
    }
}



private struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(Color(red: 40/255, green: 115/255, blue: 150/255))
            Spacer()
        }
        .padding(.leading, 4)
    }
}

private struct DefaultUnitPicker: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    let category: MeasurementCategory
    @State private var fromSelection: UnitDefinition?
    @State private var toSelection: UnitDefinition?

    var body: some View {
        ZStack {
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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "From")
                    VStack {
                        Picker("From", selection: Binding(
                            get: { fromSelection?.id ?? "" },
                            set: { newValue in fromSelection = state.units(for: category).first { $0.id == newValue } }
                        )) {
                            ForEach(state.units(for: category)) { unit in
                                Text("\(unit.name) (\(unit.symbol))").tag(unit.id)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white))

                    SectionHeader(title: "To")
                    VStack {
                        Picker("To", selection: Binding(
                            get: { toSelection?.id ?? "" },
                            set: { newValue in toSelection = state.units(for: category).first { $0.id == newValue } }
                        )) {
                            ForEach(state.units(for: category)) { unit in
                                Text("\(unit.name) (\(unit.symbol))").tag(unit.id)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white))
                }
                .padding()
            }
        }
        .gradientNavigationTitle(category.title)
        .onAppear(perform: configure)
        .onDisappear(perform: persistDefaults)
    }

    private func configure() {
        if let defaults = state.settings.defaultUnits[category] {
            fromSelection = state.unit(for: defaults.from)
            toSelection = state.unit(for: defaults.to)
        } else {
            let units = state.units(for: category)
            fromSelection = units.first
            toSelection = units.dropFirst().first ?? units.first
        }
    }

    private func persistDefaults() {
        guard let fromSelection, let toSelection else { return }
        state.setDefaultUnits(
            for: category,
            from: identity(for: fromSelection),
            to: identity(for: toSelection)
        )
    }

    private func identity(for unit: UnitDefinition) -> UnitIdentity {
        if unit.id.hasPrefix("custom."), let uuid = UUID(uuidString: String(unit.id.dropFirst(7))) {
            return .custom(uuid)
        }
        return .predefined(unit.id)
    }
}
