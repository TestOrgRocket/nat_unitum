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
            
            VStack(spacing: 0) {
                // Кастомный сегментированный контрол
                HStack(spacing: 0) {
                    ForEach(FavoritesHistoryTab.allCases) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        } label: {
                            Text(tab.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(selectedTab == tab ? .white : Color.white.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(
                                            selectedTab == tab
                                            ? Color.white.opacity(0.25)
                                            : Color.clear
                                        )
                                )
                        }
                    }
                }
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.15))
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)

            if selectedTab == .favorites {
                favoritesList
            } else {
                historyList
            }
        }
        }
    .gradientNavigationTitle("Favorites & History")
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
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.85))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        Color(
                                            red: preset.category.color.red,
                                            green: preset.category.color.green,
                                            blue: preset.category.color.blue
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                    )
                    .listRowSeparator(.hidden)
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
        .apply { view in
            if #available(iOS 16.0, *) {
                view.scrollContentBackground(.hidden)
            } else {
                view
            }
        }
        .listStyle(.plain)
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
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.85))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        Color(
                                            red: entry.category.color.red,
                                            green: entry.category.color.green,
                                            blue: entry.category.color.blue
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                    )
                    .listRowSeparator(.hidden)
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
        .apply { view in
            if #available(iOS 16.0, *) {
                view.scrollContentBackground(.hidden)
            } else {
                view
            }
        }
        .listStyle(.plain)
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
        HStack(spacing: 12) {
            // Эмоджи категории
            Text(preset.category.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 6) {
                // Конверсия с иконкой
                HStack(spacing: 8) {
                    Text(symbol(for: preset.fromUnit))
                        .font(.headline)
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.caption)
                        .foregroundColor(
                            Color(
                                red: preset.category.color.red,
                                green: preset.category.color.green,
                                blue: preset.category.color.blue
                            )
                        )
                    Text(symbol(for: preset.toUnit))
                        .font(.headline)
                }
                
                // Название или категория
                if !preset.title.isEmpty && preset.title != "\(symbol(for: preset.fromUnit)) → \(symbol(for: preset.toUnit))" {
                    Text(preset.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Последнее значение
            if let value = preset.lastInputValue {
                Text(shortFormatter.string(from: NSNumber(value: value)) ?? "")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(
                        Color(
                            red: preset.category.color.red,
                            green: preset.category.color.green,
                            blue: preset.category.color.blue
                        )
                    )
                    .accessibilityLabel("Last value \(value)")
            }
            
            // Стрелка перехода
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.leading, 36)
        .padding(.trailing, 16)
        .padding(.vertical, 14)
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

            VStack(spacing: 28) {
                // Preset Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Text(symbol(for: preset.fromUnit))
                            .font(.title.bold())
                        Image(systemName: "arrow.right")
                            .font(.title2)
                            .foregroundColor(.blue.opacity(0.7))
                        Text(symbol(for: preset.toUnit))
                            .font(.title.bold())
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    TextField("Preset name", text: Binding(
                        get: { preset.title },
                        set: { newValue in
                            preset.title = newValue
                            state.updateFavorite(preset)
                        })
                    )
                    .font(.body)
                    .padding(10)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
                    .accessibilityLabel("Preset name")
                }
                .padding(20)
                .background(Color.white.opacity(0.85))
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            Color(
                                red: state.unit(for: preset.fromUnit)?.category.color.red ?? 0.0,
                                green: state.unit(for: preset.fromUnit)?.category.color.green ?? 0.0,
                                blue: state.unit(for: preset.fromUnit)?.category.color.blue ?? 0.0
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)

                // Conversion Card
                VStack(alignment: .leading, spacing: 18) {
                    Text("Conversion")
                        .font(.headline)
                        .foregroundColor(.primary)

                    TextField("Enter value", text: $inputText)
                        .keyboardType(.decimalPad)
                        .focused($isFocused)
                        .padding(12)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(10)
                        .foregroundColor(.primary)
                        .onSubmit(convert)
                        .toolbar { ToolbarItemGroup(placement: .keyboard) { keyboardToolbar } }

                    HStack {
                        Text("Result")
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(resultText)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                            .animation(.easeInOut, value: resultText)
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.85))
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            Color(
                                red: state.unit(for: preset.fromUnit)?.category.color.red ?? 0.0,
                                green: state.unit(for: preset.fromUnit)?.category.color.green ?? 0.0,
                                blue: state.unit(for: preset.fromUnit)?.category.color.blue ?? 0.0
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)

                // Save Button
                if let numeric = resultNumeric {
                    Button(action: { exportToNotes(numeric: numeric) }) {
                        Text("Save to Notes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0),
                                        Color(red: 72.0 / 255.0, green: 202.0 / 255.0, blue: 228.0 / 255.0)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)
                    }
                    .padding(.horizontal, 8)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer()
            }
            .padding(.top, 32)
            .padding(.horizontal, 18)
        }
        .gradientNavigationTitle(preset.title.isEmpty ? "Preset" : preset.title)
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
        HStack(spacing: 12) {
            // Эмоджи категории
            Text(entry.category.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 6) {
                // Конверсия с иконкой
                HStack(spacing: 8) {
                    Text(symbol(for: entry.fromUnit))
                        .font(.headline)
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.caption)
                        .foregroundColor(
                            Color(
                                red: entry.category.color.red,
                                green: entry.category.color.green,
                                blue: entry.category.color.blue
                            )
                        )
                    Text(symbol(for: entry.toUnit))
                        .font(.headline)
                }
                
                // Значения конверсии
                HStack(spacing: 4) {
                    Text(value(entry.inputValue))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(value(entry.outputValue))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Время
            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(entry.timestamp, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Стрелка перехода
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.leading, 36)
        .padding(.trailing, 16)
        .padding(.vertical, 14)
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

            VStack(spacing: 24) {
                Spacer().frame(height: 32)
                VStack(spacing: 0) {
                    // From → To
                    HStack(spacing: 12) {
                        Text(symbol(for: entry.fromUnit))
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        Image(systemName: "arrow.right")
                            .font(.title2)
                            .foregroundColor(
                                Color(
                                    red: state.unit(for: entry.fromUnit)?.category.color.red ?? 0.0,
                                    green: state.unit(for: entry.fromUnit)?.category.color.green ?? 0.0,
                                    blue: state.unit(for: entry.fromUnit)?.category.color.blue ?? 0.0
                                )
                            )
                        Text(symbol(for: entry.toUnit))
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 18)
                    .padding(.bottom, 8)

                    Divider().padding(.horizontal, 12)

                    // Value row
                    HStack {
                        Text("Value")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(value(entry.inputValue))
                            .font(.body.weight(.semibold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)

                    Divider().padding(.horizontal, 12)

                    // Result row (accent)
                    HStack {
                        Text("Result")
                            .font(.body)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(value(entry.outputValue))
                            .font(.title2.bold())
                            .foregroundColor(
                                Color(
                                    red: state.unit(for: entry.fromUnit)?.category.color.red ?? 0.0,
                                    green: state.unit(for: entry.fromUnit)?.category.color.green ?? 0.0,
                                    blue: state.unit(for: entry.fromUnit)?.category.color.blue ?? 0.0
                                )
                            )
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                }
                .background(Color.white.opacity(0.85))
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            Color(
                                red: state.unit(for: entry.fromUnit)?.category.color.red ?? 0.0,
                                green: state.unit(for: entry.fromUnit)?.category.color.green ?? 0.0,
                                blue: state.unit(for: entry.fromUnit)?.category.color.blue ?? 0.0
                            ),
                            lineWidth: 2
                        )
                )
                .padding(.horizontal, 24)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)

                Spacer()
            }
        }
        .gradientNavigationTitle("History Entry")
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.body.weight(.semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }

    private func symbol(for identity: UnitIdentity) -> String {
        state.unit(for: identity)?.symbol ?? "—"
    }

    private func value(_ double: Double) -> String {
        MeasurementFormatterFactory.formatter(settings: state.settings).string(from: NSNumber(value: double)) ?? String(double)
    }
}
