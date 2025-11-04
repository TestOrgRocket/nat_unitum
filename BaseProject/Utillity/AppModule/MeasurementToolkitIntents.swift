#if canImport(AppIntents)
import AppIntents

@available(iOS 16.0, *)
struct ConversionPresetEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Conversion Preset")
    static var defaultQuery = FavoritePresetsQuery()

    let id: UUID
    let title: String
    let fromSymbol: String
    let toSymbol: String

    init(id: UUID, title: String, fromSymbol: String, toSymbol: String) {
        self.id = id
        self.title = title
        self.fromSymbol = fromSymbol
        self.toSymbol = toSymbol
    }

    init(preset: ConversionPreset, catalog: MeasurementCatalog, customUnits: [CustomUnit]) {
        let from = catalog.unitDefinition(for: preset.fromUnit, customUnits: customUnits)
        let to = catalog.unitDefinition(for: preset.toUnit, customUnits: customUnits)
        self.init(
            id: preset.id,
            title: preset.title.isEmpty ? "\(from?.symbol ?? "?") → \(to?.symbol ?? "?")" : preset.title,
            fromSymbol: from?.symbol ?? "?",
            toSymbol: to?.symbol ?? "?"
        )
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: title),
            subtitle: LocalizedStringResource(stringLiteral: "\(fromSymbol) → \(toSymbol)")
        )
    }
}

@available(iOS 16.0, *)
struct FavoritePresetsQuery: EntityQuery {
    func entities(for identifiers: [ConversionPresetEntity.ID]) async throws -> [ConversionPresetEntity] {
        let storage = MeasurementToolkitStorage.shared
        let all = await storage.loadFavorites()
        let custom = await storage.loadCustomUnits()
        let catalog = MeasurementCatalog.shared
        return all
            .filter { identifiers.contains($0.id) }
            .map { ConversionPresetEntity(preset: $0, catalog: catalog, customUnits: custom) }
    }

    func suggestedEntities() async throws -> [ConversionPresetEntity] {
        let storage = MeasurementToolkitStorage.shared
        let favorites = await storage.loadFavorites()
        let custom = await storage.loadCustomUnits()
        let catalog = MeasurementCatalog.shared
        return favorites.prefix(7).map { ConversionPresetEntity(preset: $0, catalog: catalog, customUnits: custom) }
    }
}

@available(iOS 16.0, *)
struct QuickConversionIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick Conversion"
    static var description = IntentDescription("Performs a saved conversion using the selected preset.")

    @Parameter(title: "Preset")
    var preset: ConversionPresetEntity

    @Parameter(title: "Value", default: 1)
    var value: Double

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let storage = MeasurementToolkitStorage.shared
        let favorites = await storage.loadFavorites()
        let custom = await storage.loadCustomUnits()
        let catalog = MeasurementCatalog.shared
        guard let match = favorites.first(where: { $0.id == preset.id }),
              let fromUnit = catalog.unitDefinition(for: match.fromUnit, customUnits: custom),
              let toUnit = catalog.unitDefinition(for: match.toUnit, customUnits: custom) else {
            throw IntentError.noMatchingPreset
        }
        let result = ConversionService.convert(value: value, from: fromUnit, to: toUnit)
        guard result.isFinite else {
            return .result(dialog: IntentDialog("Result is undefined."))
        }
        let formatter = MeasurementFormatterFactory.formatter(settings: .default)
        let formatted = formatter.string(from: NSNumber(value: result)) ?? String(result)
        return .result(dialog: IntentDialog("\(value) \(fromUnit.symbol) = \(formatted) \(toUnit.symbol)"))
    }
}

@available(iOS 16.0, *)
struct CounterEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Counter")
    static var defaultQuery = CounterQuery()

    let id: UUID
    let name: String

    init(counter: CounterItem) {
        id = counter.id
        name = counter.name
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: name))
    }
}

@available(iOS 16.0, *)
struct CounterQuery: EntityQuery {
    func entities(for identifiers: [CounterEntity.ID]) async throws -> [CounterEntity] {
        let storage = MeasurementToolkitStorage.shared
        let counters = await storage.loadCounters()
        return counters.filter { identifiers.contains($0.id) }.map(CounterEntity.init(counter:))
    }

    func suggestedEntities() async throws -> [CounterEntity] {
        let storage = MeasurementToolkitStorage.shared
        let counters = await storage.loadCounters()
        return counters.prefix(10).map(CounterEntity.init(counter:))
    }
}

@available(iOS 16.0, *)
struct IncrementCounterIntent: AppIntent {
    static var title: LocalizedStringResource = "Increment Counter"
    static var description = IntentDescription("Increases the counter by the configured step.")

    @Parameter(title: "Counter")
    var counter: CounterEntity

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let storage = MeasurementToolkitStorage.shared
        var counters = await storage.loadCounters()
        guard let index = counters.firstIndex(where: { $0.id == counter.id }) else {
            throw IntentError.noMatchingCounter
        }
        counters[index].increment()
        await storage.saveCounters(counters)
        let formatter = MeasurementFormatterFactory.formatter(settings: .default)
        let formatted = formatter.string(from: NSNumber(value: counters[index].value)) ?? String(counters[index].value)
        return .result(dialog: IntentDialog("\(counters[index].name): \(formatted)"))
    }
}

@available(iOS 16.0, *)
private enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case noMatchingPreset
    case noMatchingCounter

    @available(iOS 16, *)
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .noMatchingPreset:
            return "Preset not found"
        case .noMatchingCounter:
            return "Counter not found"
        }
    }
}

#endif
