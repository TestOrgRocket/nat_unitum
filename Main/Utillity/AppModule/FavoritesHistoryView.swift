import SwiftUI
import UIKit

enum FavoritesHistoryTab: String, CaseIterable, Identifiable {
    case favorites
    case history

    var id: String { rawValue }
    var title: String {
        switch self {
        case .favorites: return "Favorites"
        case .history: return "History"
        }
    }
}

struct FavoritesHistoryView: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    @State private var selectedTab: FavoritesHistoryTab

    init(initialTab: FavoritesHistoryTab = .favorites) {
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        VStack(spacing: 16) {
            Picker("Section", selection: $selectedTab) {
                ForEach(FavoritesHistoryTab.allCases) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if selectedTab == .favorites {
                favoritesList
            } else {
                historyList
            }
        }
    .navigationTitle("Favorites & History")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .opacity(selectedTab == .favorites ? 1 : 0)
                    .disabled(selectedTab != .favorites)
            }
        }
    }

    private var favoritesList: some View {
        List {
            if state.favorites.isEmpty {
                Text("Favorite conversions will appear here.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(state.favorites) { preset in
                    NavigationLink(destination: PresetConversionView(preset: preset)) {
                        FavoriteRow(preset: preset)
                    }
                    .accessibilityHint("Open converter for this preset")
                }
                .onDelete { indexSet in
                    state.favorites.remove(atOffsets: indexSet)
                }
                .onMove { indexSet, offset in
                    state.reorderFavorites(from: indexSet, to: offset)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var historyList: some View {
        List {
            if state.history.isEmpty {
                Text("History is empty.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(state.history) { entry in
                    NavigationLink(destination: HistoryConversionView(entry: entry)) {
                        HistoryListRow(entry: entry)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            if let from = state.unit(for: entry.fromUnit), let to = state.unit(for: entry.toUnit) {
                                let fromID = identity(for: from)
                                let toID = identity(for: to)
                                let title = "\(from.symbol) → \(to.symbol)"
                                state.toggleFavorite(category: entry.category, from: fromID, to: toID, lastValue: entry.inputValue, suggestedTitle: title)
                            }
                        } label: {
                            Label("Pin", systemImage: "star")
                        }
                        .tint(.yellow)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func identity(for unit: UnitDefinition) -> UnitIdentity {
        if unit.id.hasPrefix("custom."),
           let uuid = UUID(uuidString: String(unit.id.dropFirst(7))) {
            return .custom(uuid)
        }
        return .predefined(unit.id)
    }
}

private struct FavoriteRow: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    let preset: ConversionPreset

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                if let value = preset.lastInputValue {
                    Text(shortFormatter.string(from: NSNumber(value: value)) ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Last value \(value)")
                }
            }

            HStack(spacing: 4) {
                Text(symbol(for: preset.fromUnit))
                Image(systemName: "arrow.right")
                Text(symbol(for: preset.toUnit))
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var shortFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.locale = Locale.current
        return formatter
    }

    private func symbol(for identity: UnitIdentity) -> String {
        state.unit(for: identity)?.symbol ?? "—"
    }

    private var title: String {
        if !preset.title.isEmpty {
            return preset.title
        }
        return "\(symbol(for: preset.fromUnit)) → \(symbol(for: preset.toUnit))"
    }
}

private struct PresetConversionView: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    @State private var preset: ConversionPreset
    @State private var inputText: String
    @State private var resultText: String = "—"
    @State private var resultNumeric: Double?
    @FocusState private var isFocused: Bool

    init(preset: ConversionPreset) {
        _preset = State(initialValue: preset)
        if let value = preset.lastInputValue {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 6
            formatter.minimumFractionDigits = 0
            formatter.locale = Locale.current
            _inputText = State(initialValue: formatter.string(from: NSNumber(value: value)) ?? String(value))
        } else {
            _inputText = State(initialValue: "")
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Preset")) {
                HStack {
                    TextField("Name", text: Binding(
                        get: { preset.title },
                        set: { newValue in
                            preset.title = newValue
                            state.updateFavorite(preset)
                        }
                    ))
                        .textInputAutocapitalization(.words)
                        .accessibilityLabel("Preset name")
                }

                HStack {
                    Text(symbol(for: preset.fromUnit))
                    Image(systemName: "arrow.right")
                    Text(symbol(for: preset.toUnit))
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }

            Section(header: Text("Conversion")) {
                TextField("0", text: $inputText)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .onSubmit(convert)
                    .toolbar { ToolbarItemGroup(placement: .keyboard) { keyboardToolbar } }

                HStack {
                    Text("Result")
                    Spacer()
                    Text(resultText)
                        .font(.body.weight(.semibold))
                }
            }

            if let numeric = resultNumeric {
                Section {
                    Button("Save to Notes") {
                        exportToNotes(numeric: numeric)
                    }
                }
            }
        }
    .navigationTitle(preset.title.isEmpty ? "Preset" : preset.title)
        .onAppear(perform: convert)
    }

    private func symbol(for identity: UnitIdentity) -> String {
        state.unit(for: identity)?.symbol ?? "—"
    }

    private func convert() {
        guard let fromUnit = state.unit(for: preset.fromUnit),
              let toUnit = state.unit(for: preset.toUnit) else {
            resultText = "—"
            return
        }
        let numberFormatter = MeasurementFormatterFactory.formatter(settings: state.settings)
        let doubleValue = numberFormatter.number(from: inputText)?.doubleValue ?? Double(inputText.replacingOccurrences(of: ",", with: "."))
        guard let value = doubleValue else {
            resultText = "—"
            resultNumeric = nil
            return
        }
        let converted = ConversionService.convert(value: value, from: fromUnit, to: toUnit)
        guard converted.isFinite else {
            resultText = "—"
            resultNumeric = nil
            return
        }
        resultNumeric = converted
        resultText = numberFormatter.string(from: NSNumber(value: converted)) ?? String(converted)
        preset.lastInputValue = value
        state.updateFavorite(preset)
    }

    private var keyboardToolbar: some View {
        HStack {
            Spacer()
            Button("Done") {
                isFocused = false
                convert()
            }
        }
    }

    private func exportToNotes(numeric: Double) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let text = "\(formatter.string(from: Date()))\n\(preset.title) = \(numeric)"
        UIPasteboard.general.string = text
    }
}

private struct HistoryListRow: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    let entry: ConversionHistoryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(symbol(for: entry.fromUnit))
                Image(systemName: "arrow.right")
                Text(symbol(for: entry.toUnit))
                Spacer()
                Text(entry.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text("\(value(entry.inputValue)) → \(value(entry.outputValue))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func symbol(for identity: UnitIdentity) -> String {
        state.unit(for: identity)?.symbol ?? "—"
    }

    private func value(_ double: Double) -> String {
        MeasurementFormatterFactory.formatter(settings: state.settings).string(from: NSNumber(value: double)) ?? String(double)
    }
}

private struct HistoryConversionView: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    let entry: ConversionHistoryEntry

    var body: some View {
        Form {
            Section(header: Text("Conversion")) {
                HStack {
                    Text("From")
                    Spacer()
                    Text(symbol(for: entry.fromUnit))
                }
                HStack {
                    Text("To")
                    Spacer()
                    Text(symbol(for: entry.toUnit))
                }
                HStack {
                    Text("Value")
                    Spacer()
                    Text(value(entry.inputValue))
                }
                HStack {
                    Text("Result")
                    Spacer()
                    Text(value(entry.outputValue))
                }
            }
        }
    .navigationTitle("History Entry")
    }

    private func symbol(for identity: UnitIdentity) -> String {
        state.unit(for: identity)?.symbol ?? "—"
    }

    private func value(_ double: Double) -> String {
        MeasurementFormatterFactory.formatter(settings: state.settings).string(from: NSNumber(value: double)) ?? String(double)
    }
}
