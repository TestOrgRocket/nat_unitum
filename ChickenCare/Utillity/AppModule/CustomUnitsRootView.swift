import SwiftUI

struct CustomUnitsRootView: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    @State private var isPresentingNewUnit = false

    var body: some View {
        List {
            ForEach(MeasurementCategory.allCases, id: \.id) { category in
                Section(header: Text(category.title)) {
                    let units = state.customUnits.filter { $0.category == category }
                    if units.isEmpty {
                        Text("No custom units yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(units) { unit in
                            NavigationLink(destination: CustomUnitEditor(unit: unit)) {
                                VStack(alignment: .leading) {
                                    Text(unit.name)
                                        .font(.headline)
                                    Text("1 \(unit.symbol) = \(format(unit.multiplierToBase)) × \(baseSymbol(for: category))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    state.deleteCustomUnit(unit)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Custom Units")
        .toolbar {
            Button {
                isPresentingNewUnit = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $isPresentingNewUnit) {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    CustomUnitEditor(unit: CustomUnit(category: .length, name: "", symbol: "", multiplierToBase: 1), isNew: true)
                }
                .presentationDetents([.medium, .large])
            } else {
                NavigationView {
                    CustomUnitEditor(unit: CustomUnit(category: .length, name: "", symbol: "", multiplierToBase: 1), isNew: true)
                }
            }
        }
    }

    private func format(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    private func baseSymbol(for category: MeasurementCategory) -> String {
        state.catalog.baseUnit(for: category)?.symbol ?? "?"
    }
}

private struct CustomUnitEditor: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    @Environment(\.dismiss) private var dismiss
    @State private var unit: CustomUnit
    @State private var errorMessage: String?
    private let isNew: Bool

    init(unit: CustomUnit, isNew: Bool = false) {
        _unit = State(initialValue: unit)
        self.isNew = isNew
    }

    var body: some View {
        Form {
            Section(header: Text("Details")) {
                Picker("Category", selection: $unit.category) {
                    ForEach(MeasurementCategory.allCases.filter(canUseForCustom), id: \.id) { category in
                        Text(category.title).tag(category)
                    }
                }

                TextField("Name", text: $unit.name)
                    .textInputAutocapitalization(.words)

                TextField("Symbol", text: $unit.symbol)
                    .autocapitalization(.allCharacters)

                TextField("Multiplier", value: $unit.multiplierToBase, format: .number)
                    .keyboardType(.decimalPad)
            }

            Section(header: Text("Preview")) {
                Text("1 \(unit.symbol.isEmpty ? "—" : unit.symbol) = \(format(unit.multiplierToBase)) × \(baseSymbol)")
                    .font(.callout)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle(isNew ? "New Unit" : unit.name)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(unit.name.trimmingCharacters(in: .whitespaces).isEmpty || unit.symbol.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func save() {
        do {
            if isNew {
                try state.addCustomUnit(unit)
            } else {
                try state.updateCustomUnit(unit)
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func canUseForCustom(_ category: MeasurementCategory) -> Bool {
        category != .temperature // preventing affine requirements for now
    }

    private var baseSymbol: String {
        state.catalog.baseUnit(for: unit.category)?.symbol ?? "?"
    }

    private func format(_ multiplier: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: multiplier)) ?? String(multiplier)
    }
}
