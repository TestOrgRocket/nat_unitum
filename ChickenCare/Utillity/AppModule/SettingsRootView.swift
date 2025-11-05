import SwiftUI

struct SettingsRootView: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    @State private var precision: Double = 2

    var body: some View {
        Form {
            Section(header: Text("Precision")) {
                Stepper(value: $precision, in: 0...6, step: 1) {
                    Text("Decimal places: \(Int(precision))")
                }
                .onChange(of: precision) { newValue in
                    state.updatePrecision(Int(newValue))
                }
            }

            Section(header: Text("Format")) {
                Toggle("Use grouping separators", isOn: Binding(
                    get: { state.settings.groupingSeparatorEnabled },
                    set: { newValue in
                        state.settings.groupingSeparatorEnabled = newValue
                    }
                ))
            }

            Section(header: Text("Defaults")) {
                ForEach(MeasurementCategory.allCases, id: \.id) { category in
                    NavigationLink(category.title) {
                        DefaultUnitPicker(category: category)
                    }
                }
            }

            Section(header: Text("Data")) {
                Button("Clear history") {
                    state.history.removeAll()
                }
                .foregroundColor(.red)
            }
        }
        .onAppear {
            precision = Double(state.settings.precision)
        }
        .navigationTitle("Settings")
    }
}

private struct DefaultUnitPicker: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    let category: MeasurementCategory
    @State private var fromSelection: UnitDefinition?
    @State private var toSelection: UnitDefinition?

    var body: some View {
        Form {
            Section(header: Text("From")) {
                Picker("From", selection: Binding(
                    get: { fromSelection?.id ?? "" },
                    set: { newValue in fromSelection = state.units(for: category).first { $0.id == newValue } }
                )) {
                    ForEach(state.units(for: category)) { unit in
                        Text("\(unit.name) (\(unit.symbol))").tag(unit.id)
                    }
                }
            }

            Section(header: Text("To")) {
                Picker("To", selection: Binding(
                    get: { toSelection?.id ?? "" },
                    set: { newValue in toSelection = state.units(for: category).first { $0.id == newValue } }
                )) {
                    ForEach(state.units(for: category)) { unit in
                        Text("\(unit.name) (\(unit.symbol))").tag(unit.id)
                    }
                }
            }
        }
        .navigationTitle(category.title)
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
