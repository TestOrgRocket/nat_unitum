import SwiftUI

struct ConverterRootView: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    @State private var selectedCategory: MeasurementCategory = .length
    @State private var fromUnit: UnitDefinition?
    @State private var toUnit: UnitDefinition?
    @State private var inputText: String = ""
    @State private var resultText: String = "—"
    @State private var pendingNumericResult: Double?
    @FocusState private var isInputFocused: Bool

    private var formatter: NumberFormatter {
        MeasurementFormatterFactory.formatter(settings: state.settings)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                categorySelector
                converterCard
                historySection
            }
            .padding(.horizontal)
            .padding(.top)
        }
    .navigationTitle("Converter")
        .toolbar { ToolbarItemGroup(placement: .keyboard) { keyboardToolbar } }
        .onAppear { configureDefaults() }
        .onChange(of: state.settings) { _ in updateResult() }
        .onChange(of: selectedCategory) { _ in applyCategorySelection() }
        .onChange(of: inputText) { _ in updateResult() }
        .onChange(of: fromUnit?.id) { _ in updateResult() }
        .onChange(of: toUnit?.id) { _ in updateResult() }
    }

    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MeasurementCategory.allCases, id: \.id) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category.title)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.15))
                            .foregroundColor(selectedCategory == category ? .accentColor : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .accessibilityLabel("Category " + category.title)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var converterCard: some View {
        VStack(spacing: 16) {
            conversionRow(title: "From", value: $inputText, unit: $fromUnit, isEditable: true)
            conversionRow(title: "To", value: .constant(resultText), unit: $toUnit, isEditable: false)

            HStack(spacing: 16) {
                Button(action: swapUnits) {
                    Label("Swap", systemImage: "arrow.triangle.swap")
                }
                .buttonStyle(.borderedProminent)

                Button(action: multiplyInput) {
                    Text("×10")
                }
                .buttonStyle(.bordered)

                Button(action: divideInput) {
                    Text("÷10")
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(action: toggleFavorite) {
                    Label("Favorite", systemImage: favoriteStateImage)
                        .labelStyle(.iconOnly)
                        .foregroundColor(isFavorite ? .yellow : .primary)
                        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color(uiColor: .secondarySystemBackground)))
        .accessibilityElement(children: .contain)
    }

    private func conversionRow(title: String, value: Binding<String>, unit: Binding<UnitDefinition?>, isEditable: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                if isEditable {
                    TextField("0", text: value)
                        .keyboardType(.decimalPad)
                        .focused($isInputFocused)
                        .submitLabel(.done)
                        .onSubmit { commitConversion() }
                        .accessibilityIdentifier("converter.input")
                } else {
                    Text(value.wrappedValue.isEmpty ? "—" : value.wrappedValue)
                        .font(.title3.weight(.semibold))
                        .accessibilityIdentifier("converter.output")
                }

                Spacer()

                Menu {
                    ForEach(state.units(for: selectedCategory)) { descriptor in
                        Button {
                            unit.wrappedValue = descriptor
                        } label: {
                            HStack {
                                Text(descriptor.name)
                                Spacer()
                                Text(descriptor.symbol)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(unit.wrappedValue?.symbol ?? "—")
                            .font(.headline)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .accessibilityLabel("Select unit for \(title) field")
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(uiColor: .secondarySystemGroupedBackground)))
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("History")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: FavoritesHistoryView(initialTab: .history)) {
                    Text("Show All")
                }
            }

            if state.history.isEmpty {
                Text("History is empty for now.")
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(state.history.prefix(5)) { entry in
                        HistoryRow(entry: entry)
                    }
                }
            }
        }
    }

    private var favoriteStateImage: String {
        isFavorite ? "star.fill" : "star"
    }

    private var isFavorite: Bool {
        guard let fromUnit, let toUnit else { return false }
        let fromIdentity = identity(for: fromUnit)
        let toIdentity = identity(for: toUnit)
        return state.isFavorite(category: selectedCategory, from: fromIdentity, to: toIdentity) != nil
    }

    private func identity(for unit: UnitDefinition) -> UnitIdentity {
        if unit.id.hasPrefix("custom.") {
            if let uuid = UUID(uuidString: String(unit.id.dropFirst(7))) {
                return .custom(uuid)
            }
        }
        return .predefined(unit.id)
    }

    private func configureDefaults() {
        guard fromUnit == nil else { return }
        selectedCategory = .length
        applyCategorySelection()
    }

    private func applyCategorySelection() {
        let units = state.units(for: selectedCategory)
        if units.isEmpty {
            fromUnit = nil
            toUnit = nil
            return
        }

          if let defaultPair = state.settings.defaultUnits[selectedCategory],
              let fromDescriptor = state.unit(for: defaultPair.from),
              let toDescriptor = state.unit(for: defaultPair.to) {
            fromUnit = fromDescriptor
            toUnit = toDescriptor
        } else {
            fromUnit = units.first
            toUnit = units.dropFirst().first ?? units.first
        }

        updateResult()
    }

    private func swapUnits() {
        guard let fromUnit, let toUnit else { return }
        self.fromUnit = toUnit
        self.toUnit = fromUnit
        updateResult()
    }

    private func multiplyInput() {
        guard !inputText.isEmpty else { return }
        if let value = formatter.number(from: inputText)?.doubleValue {
            inputText = formatter.string(from: NSNumber(value: value * 10)) ?? ""
        } else if let value = Double(inputText.replacingOccurrences(of: ",", with: ".")) {
            inputText = formatter.string(from: NSNumber(value: value * 10)) ?? ""
        }
        updateResult(logHistory: true)
    }

    private func divideInput() {
        guard !inputText.isEmpty else { return }
        if let value = formatter.number(from: inputText)?.doubleValue {
            inputText = formatter.string(from: NSNumber(value: value / 10)) ?? ""
        } else if let value = Double(inputText.replacingOccurrences(of: ",", with: ".")) {
            inputText = formatter.string(from: NSNumber(value: value / 10)) ?? ""
        }
        updateResult(logHistory: true)
    }

    private func toggleFavorite() {
        guard let fromUnit, let toUnit else { return }
        let fromIdentity = identity(for: fromUnit)
        let toIdentity = identity(for: toUnit)
        let suggestedTitle = "\(fromUnit.symbol) → \(toUnit.symbol)"
        let numeric = pendingNumericResult ?? formatter.number(from: resultText)?.doubleValue
        state.toggleFavorite(category: selectedCategory, from: fromIdentity, to: toIdentity, lastValue: numeric, suggestedTitle: suggestedTitle)
    }

    private func commitConversion() {
        updateResult(logHistory: true)
    }

    private func updateResult(logHistory: Bool = false) {
        guard let fromUnit, let toUnit else {
            resultText = "—"
            return
        }

        guard let inputNumber = parseInput() else {
            resultText = "—"
            return
        }

        let converted = ConversionService.convert(value: inputNumber, from: fromUnit, to: toUnit)
        guard converted.isFinite else {
            resultText = "—"
            return
        }
        pendingNumericResult = converted
        resultText = formatter.string(from: NSNumber(value: converted)) ?? String(converted)

        if logHistory {
            state.addHistoryEntry(
                category: selectedCategory,
                from: identity(for: fromUnit),
                to: identity(for: toUnit),
                input: inputNumber,
                output: converted
            )
        }
    }

    private func parseInput() -> Double? {
        if let number = formatter.number(from: inputText)?.doubleValue {
            return number
        }
        // Secondary attempt for manual decimal separators
        return Double(inputText.replacingOccurrences(of: ",", with: "."))
    }

    private var keyboardToolbar: some View {
        HStack {
            Spacer()
            Button("Done") {
                isInputFocused = false
                commitConversion()
            }
        }
    }
}

private struct HistoryRow: View {
    let entry: ConversionHistoryEntry
    @EnvironmentObject private var state: MeasurementToolkitState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(symbol(from: entry.fromUnit))
                Image(systemName: "arrow.right")
                Text(symbol(from: entry.toUnit))
                Spacer()
                Text(timestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)

            Text(valueLine)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(uiColor: .tertiarySystemBackground)))
    }

    private var timestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: entry.timestamp, relativeTo: Date())
    }

    private func symbol(from identity: UnitIdentity) -> String {
        state.unit(for: identity)?.symbol ?? "?"
    }

    private var valueLine: String {
        let formatter = MeasurementFormatterFactory.formatter(settings: state.settings)
        let input = formatter.string(from: NSNumber(value: entry.inputValue)) ?? String(entry.inputValue)
        let output = formatter.string(from: NSNumber(value: entry.outputValue)) ?? String(entry.outputValue)
        return "\(input) → \(output)"
    }
}
