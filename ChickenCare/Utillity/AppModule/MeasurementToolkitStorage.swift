import Foundation

/// Lightweight persistence layer backed by shared user defaults.
actor MeasurementToolkitStorage {
    static let shared = MeasurementToolkitStorage()

    private struct Keys {
        static let settings = "appmodule.measurement.settings"
        static let favorites = "appmodule.measurement.favorites"
        static let history = "appmodule.measurement.history"
        static let counters = "appmodule.measurement.counters"
        static let customUnits = "appmodule.measurement.customUnits"
        static let stopwatch = "appmodule.measurement.stopwatch"
    }

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        if let sharedDefaults = UserDefaults(suiteName: "com.chickcare.measurementtoolkit") {
            defaults = sharedDefaults
        } else {
            defaults = .standard
        }
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadSettings() -> ToolkitSettings {
        guard let data = defaults.data(forKey: Keys.settings), let settings = try? decoder.decode(ToolkitSettings.self, from: data) else {
            return .default
        }
        return settings
    }

    func saveSettings(_ settings: ToolkitSettings) {
        if let data = try? encoder.encode(settings) {
            defaults.set(data, forKey: Keys.settings)
        }
    }

    func loadFavorites() -> [ConversionPreset] {
        guard let data = defaults.data(forKey: Keys.favorites), let items = try? decoder.decode([ConversionPreset].self, from: data) else {
            return []
        }
        return items
    }

    func saveFavorites(_ presets: [ConversionPreset]) {
        if let data = try? encoder.encode(presets) {
            defaults.set(data, forKey: Keys.favorites)
        }
    }

    func loadHistory() -> [ConversionHistoryEntry] {
        guard let data = defaults.data(forKey: Keys.history), let items = try? decoder.decode([ConversionHistoryEntry].self, from: data) else {
            return []
        }
        return items.sorted { $0.timestamp > $1.timestamp }
    }

    func saveHistory(_ history: [ConversionHistoryEntry]) {
        if let data = try? encoder.encode(Array(history.prefix(20))) {
            defaults.set(data, forKey: Keys.history)
        }
    }

    func loadCounters() -> [CounterItem] {
        guard let data = defaults.data(forKey: Keys.counters), let items = try? decoder.decode([CounterItem].self, from: data) else {
            return []
        }
        return items
    }

    func saveCounters(_ counters: [CounterItem]) {
        if let data = try? encoder.encode(counters) {
            defaults.set(data, forKey: Keys.counters)
        }
    }

    func loadCustomUnits() -> [CustomUnit] {
        guard let data = defaults.data(forKey: Keys.customUnits), let items = try? decoder.decode([CustomUnit].self, from: data) else {
            return []
        }
        return items
    }

    func saveCustomUnits(_ units: [CustomUnit]) {
        if let data = try? encoder.encode(units) {
            defaults.set(data, forKey: Keys.customUnits)
        }
    }

    func loadStopwatchLogs() -> [StopwatchLog] {
        guard let data = defaults.data(forKey: Keys.stopwatch), let items = try? decoder.decode([StopwatchLog].self, from: data) else {
            return []
        }
        return items.sorted { $0.recordedAt > $1.recordedAt }
    }

    func saveStopwatchLogs(_ logs: [StopwatchLog]) {
        if let data = try? encoder.encode(logs) {
            defaults.set(data, forKey: Keys.stopwatch)
        }
    }
}
