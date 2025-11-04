#if canImport(WidgetKit)
import WidgetKit
import SwiftUI

@available(iOS 17.0, *)
struct MeasurementToolkitWidgetBundle: WidgetBundle {
    var body: some Widget {
        FavoriteConversionWidget()
        CounterQuickWidget()
    }
}

struct FavoriteConversionEntry: TimelineEntry {
    let date: Date
    let preset: ConversionPreset?
    let fromUnit: UnitDefinition?
    let toUnit: UnitDefinition?
    let result: Double?
}

struct FavoriteConversionProvider: TimelineProvider {
    func placeholder(in context: Context) -> FavoriteConversionEntry {
        FavoriteConversionEntry(date: Date(), preset: nil, fromUnit: nil, toUnit: nil, result: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (FavoriteConversionEntry) -> Void) {
        Task {
            let entry = await loadEntry()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FavoriteConversionEntry>) -> Void) {
        Task {
            let entry = await loadEntry()
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(1_800)))
            completion(timeline)
        }
    }

    private func loadEntry() async -> FavoriteConversionEntry {
        let storage = MeasurementToolkitStorage.shared
        let favorites = await storage.loadFavorites()
        let custom = await storage.loadCustomUnits()
        guard let preset = favorites.first else {
            return FavoriteConversionEntry(date: Date(), preset: nil, fromUnit: nil, toUnit: nil, result: nil)
        }
        let catalog = MeasurementCatalog.shared
        let baseValue = preset.lastInputValue ?? 1
        let from = catalog.unitDefinition(for: preset.fromUnit, customUnits: custom)
        let to = catalog.unitDefinition(for: preset.toUnit, customUnits: custom)
        let result = (from != nil && to != nil) ? ConversionService.convert(value: baseValue, from: from!, to: to!) : nil
        return FavoriteConversionEntry(date: Date(), preset: preset, fromUnit: from, toUnit: to, result: result)
    }
}

@available(iOS 17.0, *)
struct FavoriteConversionWidget: Widget {
    let kind: String = "FavoriteConversionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FavoriteConversionProvider()) { entry in
            FavoriteConversionWidgetView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Quick Converter")
        .description("Shows the result of the selected conversion and its latest input value.")
    }
}

@available(iOS 17.0, *)
struct FavoriteConversionWidgetView: View {
    let entry: FavoriteConversionEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.preset?.title ?? "No favorites yet")
                .font(.headline)
            if let from = entry.fromUnit, let to = entry.toUnit, let result = entry.result {
                Text("1 \(from.symbol) = \(formatted(result: result)) \(to.symbol)")
                    .font(.body)
            } else {
                Text("Add a preset in the app")
                    .font(.caption)
            }
        }
        .padding()
        .containerBackground(Color(.secondarySystemBackground), for: .widget)
    }

    private func formatted(result: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        return formatter.string(from: NSNumber(value: result)) ?? String(result)
    }
}

struct CounterEntry: TimelineEntry {
    let date: Date
    let counter: CounterItem?
}

struct CounterProvider: TimelineProvider {
    func placeholder(in context: Context) -> CounterEntry {
        CounterEntry(date: Date(), counter: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (CounterEntry) -> Void) {
        Task { completion(await loadEntry()) }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CounterEntry>) -> Void) {
        Task {
            let entry = await loadEntry()
            completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900))))
        }
    }

    private func loadEntry() async -> CounterEntry {
        let storage = MeasurementToolkitStorage.shared
        let counters = await storage.loadCounters()
        return CounterEntry(date: Date(), counter: counters.first)
    }
}

@available(iOS 17.0, *)
struct CounterQuickWidget: Widget {
    let kind: String = "CounterQuickWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CounterProvider()) { entry in
            CounterWidgetView(entry: entry)
        }
        .configurationDisplayName("Quick Counter")
        .description("Displays the value of the selected counter.")
        .supportedFamilies([.systemSmall])
    }
}

@available(iOS 17.0, *)
struct CounterWidgetView: View {
    let entry: CounterEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.counter?.name ?? "No counters available")
                .font(.headline)
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
        }
        .padding()
        .containerBackground(Color(.secondarySystemBackground), for: .widget)
    }

    private var value: String {
        guard let counter = entry.counter else { return "—" }
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: counter.value)) ?? String(counter.value)
    }
}

#endif
