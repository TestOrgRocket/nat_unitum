import Foundation

/// Shared observable state that powers the measurement toolkit module.
@MainActor
public final class MeasurementToolkitState: ObservableObject {
    public static let shared = MeasurementToolkitState()

    @Published var settings: ToolkitSettings = .default {
        didSet { Task { await storage.saveSettings(settings) } }
    }
    @Published var favorites: [ConversionPreset] = [] {
        didSet { Task { await storage.saveFavorites(favorites) } }
    }
    @Published var history: [ConversionHistoryEntry] = [] {
        didSet { Task { await storage.saveHistory(history) } }
    }
    @Published var counters: [CounterItem] = [] {
        didSet { Task { await storage.saveCounters(counters) } }
    }
    @Published var customUnits: [CustomUnit] = [] {
        didSet { Task { await storage.saveCustomUnits(customUnits) } }
    }
    @Published var stopwatchLogs: [StopwatchLog] = [] {
        didSet { Task { await storage.saveStopwatchLogs(stopwatchLogs) } }
    }

    let catalog = MeasurementCatalog.shared

    private let storage = MeasurementToolkitStorage.shared

    public init() {
        Task {
            await hydrate()
        }
    }

    public func hydrate() async {
        let settings = await storage.loadSettings()
        let favorites = await storage.loadFavorites()
        let history = await storage.loadHistory()
        let counters = await storage.loadCounters()
        let customUnits = await storage.loadCustomUnits()
        let stopwatchLogs = await storage.loadStopwatchLogs()

        await MainActor.run {
            self.settings = settings
            self.favorites = favorites
            self.history = history
            self.counters = counters
            self.customUnits = customUnits
            self.stopwatchLogs = stopwatchLogs
        }
    }

    // MARK: - Units & Conversions

    func units(for category: MeasurementCategory) -> [UnitDefinition] {
        catalog.units(for: category, customUnits: customUnits)
    }

    func unit(for identity: UnitIdentity) -> UnitDefinition? {
        catalog.unitDefinition(for: identity, customUnits: customUnits)
    }

    func addHistoryEntry(category: MeasurementCategory, from: UnitIdentity, to: UnitIdentity, input: Double, output: Double) {
        let entry = ConversionHistoryEntry(
            category: category,
            fromUnit: from,
            toUnit: to,
            inputValue: input,
            outputValue: output,
            precision: settings.precision
        )
        history.insert(entry, at: 0)
        if history.count > 20 {
            history = Array(history.prefix(20))
        }
    }

    func toggleFavorite(category: MeasurementCategory, from: UnitIdentity, to: UnitIdentity, lastValue: Double?, suggestedTitle: String) {
        if let index = favorites.firstIndex(where: { $0.category == category && $0.fromUnit == from && $0.toUnit == to }) {
            favorites.remove(at: index)
        } else {
            let preset = ConversionPreset(title: suggestedTitle, category: category, fromUnit: from, toUnit: to, lastInputValue: lastValue)
            favorites.insert(preset, at: 0)
        }
    }

    func updateFavorite(_ preset: ConversionPreset) {
        guard let index = favorites.firstIndex(where: { $0.id == preset.id }) else { return }
        favorites[index] = preset
    }

    func reorderFavorites(from source: IndexSet, to destination: Int) {
        favorites.move(fromOffsets: source, toOffset: destination)
    }

    func isFavorite(category: MeasurementCategory, from: UnitIdentity, to: UnitIdentity) -> ConversionPreset? {
        favorites.first { $0.category == category && $0.fromUnit == from && $0.toUnit == to }
    }

    // MARK: - Counters

    func addCounter(_ counter: CounterItem) {
        counters.append(counter)
    }

    func updateCounter(_ counter: CounterItem) {
        guard let index = counters.firstIndex(where: { $0.id == counter.id }) else { return }
        counters[index] = counter
    }

    func removeCounter(_ counter: CounterItem) {
        counters.removeAll { $0.id == counter.id }
    }

    func resetCounter(_ counter: CounterItem) {
        guard let index = counters.firstIndex(where: { $0.id == counter.id }) else { return }
        counters[index].value = 0
    }

    // MARK: - Stopwatch

    func appendStopwatchLog(duration: TimeInterval) {
        let log = StopwatchLog(duration: duration)
        stopwatchLogs.insert(log, at: 0)
    }

    // MARK: - Custom Units

    func addCustomUnit(_ unit: CustomUnit) throws {
        guard unit.multiplierToBase > 0 else {
            throw ValidationError.invalidMultiplier
        }
        if catalog.hasSymbolConflict(unit.symbol, category: unit.category, customUnits: customUnits) {
            throw ValidationError.duplicateSymbol
        }
        customUnits.append(unit)
    }

    func updateCustomUnit(_ unit: CustomUnit) throws {
        guard unit.multiplierToBase > 0 else {
            throw ValidationError.invalidMultiplier
        }
        if catalog.hasSymbolConflict(unit.symbol, category: unit.category, customUnits: customUnits, excluding: unit.id) {
            throw ValidationError.duplicateSymbol
        }
        if let index = customUnits.firstIndex(where: { $0.id == unit.id }) {
            customUnits[index] = unit
        }
    }

    func deleteCustomUnit(_ unit: CustomUnit) {
        customUnits.removeAll { $0.id == unit.id }
    }

    // MARK: - Settings

    func updatePrecision(_ value: Int) {
        settings.precision = max(0, min(6, value))
    }

    func toggleGrouping() {
        settings.groupingSeparatorEnabled.toggle()
    }

    func setDefaultUnits(for category: MeasurementCategory, from: UnitIdentity, to: UnitIdentity) {
        settings.defaultUnits[category] = ToolkitSettings.UnitPreference(from: from, to: to)
    }

    // MARK: - Errors

    enum ValidationError: LocalizedError {
        case invalidMultiplier
        case duplicateSymbol

        var errorDescription: String? {
            switch self {
            case .invalidMultiplier:
                return "Multiplier must be greater than zero."
            case .duplicateSymbol:
                return "A unit with this symbol already exists."
            }
        }
    }
}
