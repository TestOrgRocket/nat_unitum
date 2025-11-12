import SwiftUI

struct CustomUnitsRootView: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    @State private var isPresentingNewUnit = false

    // Appearance scoped to the hosting controller — moved to AppModule.MeasurementToolkit
    // so we don't affect other tables in the app.

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
            
            List {
                ForEach(MeasurementCategory.allCases, id: \.id) { category in
                    Section(header: sectionHeader(category)) {
                        let units = state.customUnits.filter { $0.category == category }

                        if units.isEmpty {
                            // Empty-state pill
                            HStack {
                                Text("No custom units yet.")
                                    .font(.body)
                                    .foregroundColor(Color(white: 0.45))
                                    .padding(.vertical, 18)
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color.panelBackground)
                                            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 4)
                                    )
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                        } else {
                            ForEach(units) { unit in
                                NavigationLink(destination: CustomUnitEditor(unit: unit)) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(unit.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("1 \(unit.symbol) = \(format(unit.multiplierToBase)) × \(baseSymbol(for: category))")
                                            .font(.caption)
                                            .foregroundColor(Color(white: 0.45))
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color.panelBackground)
                                            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                                    )
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowBackground(Color.clear)
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
            .listStyle(PlainListStyle())
            .apply { view in
                if #available(iOS 16.0, *) {
                    view.scrollContentBackground(.hidden)
                } else {
                    view
                }
            }
        }
        .gradientNavigationTitle("Custom Units")
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

    @ViewBuilder
    private func sectionHeader(_ category: MeasurementCategory) -> some View {
        HStack {
            Text(category.title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(Color(red: 40/255, green: 115/255, blue: 150/255))
            Spacer()
        }
        .padding(.leading, 16)
        .padding(.top, 8)
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
            .listRowBackground(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.panelBackground)
                    .padding(.vertical, 4)
            )

            Section(header: Text("Preview")) {
                Text("1 \(unit.symbol.isEmpty ? "—" : unit.symbol) = \(format(unit.multiplierToBase)) × \(baseSymbol)")
                    .font(.callout)
            }
            .listRowBackground(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.panelBackground)
                    .padding(.vertical, 4)
            )

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.panelBackground)
                        .padding(.vertical, 4)
                )
            }
        }
        .apply { view in
            if #available(iOS 16.0, *) {
                view.scrollContentBackground(.hidden)
            } else {
                view
            }
        }
        }
        .gradientNavigationTitle(isNew ? "New Unit" : unit.name)
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
