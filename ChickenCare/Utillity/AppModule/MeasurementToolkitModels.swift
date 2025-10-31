import Foundation

// MARK: - Measurement Catalog

/// Supported conversion categories.
public enum MeasurementCategory: String, CaseIterable, Codable, Identifiable {
    case length = "Length"
    case mass = "Mass"
    case volume = "Volume"
    case area = "Area"
    case speed = "Speed"
    case temperature = "Temperature"
    case pressure = "Pressure"
    case energy = "Energy"
    case force = "Force"
    case time = "Time"
    case angle = "Angle"
    case fuelConsumption = "Fuel Consumption"

    public var id: String { rawValue }

    /// Human readable localized title placeholder.
    var title: String {
        switch self {
        case .length: return "Length"
        case .mass: return "Mass"
        case .volume: return "Volume"
        case .area: return "Area"
        case .speed: return "Speed"
        case .temperature: return "Temperature"
        case .pressure: return "Pressure"
        case .energy: return "Energy"
        case .force: return "Force"
        case .time: return "Time"
        case .angle: return "Angle"
        case .fuelConsumption: return "Fuel Consumption"
        }
    }
}

/// Linear or specialised conversion strategies.
public enum UnitConverter: Equatable, Hashable, Codable {
    case linear(multiplier: Double)
    case affine(scale: Double, offset: Double)
    case reciprocal(multiplier: Double)
    case temperature(TemperatureUnit)

    public enum CodingKeys: String, CodingKey {
        case type
        case multiplier
        case scale
        case offset
        case unit
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "linear":
            let multiplier = try container.decode(Double.self, forKey: .multiplier)
            self = .linear(multiplier: multiplier)
        case "affine":
            let scale = try container.decode(Double.self, forKey: .scale)
            let offset = try container.decode(Double.self, forKey: .offset)
            self = .affine(scale: scale, offset: offset)
        case "reciprocal":
            let multiplier = try container.decode(Double.self, forKey: .multiplier)
            self = .reciprocal(multiplier: multiplier)
        case "temperature":
            let unit = try container.decode(TemperatureUnit.self, forKey: .unit)
            self = .temperature(unit)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unsupported converter type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .linear(let multiplier):
            try container.encode("linear", forKey: .type)
            try container.encode(multiplier, forKey: .multiplier)
        case .affine(let scale, let offset):
            try container.encode("affine", forKey: .type)
            try container.encode(scale, forKey: .scale)
            try container.encode(offset, forKey: .offset)
        case .reciprocal(let multiplier):
            try container.encode("reciprocal", forKey: .type)
            try container.encode(multiplier, forKey: .multiplier)
        case .temperature(let unit):
            try container.encode("temperature", forKey: .type)
            try container.encode(unit, forKey: .unit)
        }
    }
}

/// Explicit temperature unit support for non-linear conversions.
public enum TemperatureUnit: String, Codable, CaseIterable {
    case kelvin
    case celsius
    case fahrenheit
}

/// Descriptor for both predefined and custom units.
public struct UnitDefinition: Identifiable, Codable, Hashable {
    public let id: String
    public let category: MeasurementCategory
    public let name: String
    public let symbol: String
    public let converter: UnitConverter
    public let isSystemUnit: Bool

    public init(id: String, category: MeasurementCategory, name: String, symbol: String, converter: UnitConverter, isSystemUnit: Bool = false) {
        self.id = id
        self.category = category
        self.name = name
        self.symbol = symbol
        self.converter = converter
        self.isSystemUnit = isSystemUnit
    }
}

/// User defined unit persisted in app storage.
public struct CustomUnit: Identifiable, Codable, Hashable {
    public let id: UUID
    public var category: MeasurementCategory
    public var name: String
    public var symbol: String
    public var multiplierToBase: Double

    public init(id: UUID = UUID(), category: MeasurementCategory, name: String, symbol: String, multiplierToBase: Double) {
        self.id = id
        self.category = category
        self.name = name
        self.symbol = symbol
        self.multiplierToBase = multiplierToBase
    }

    var definition: UnitDefinition {
        UnitDefinition(
            id: "custom." + id.uuidString,
            category: category,
            name: name,
            symbol: symbol,
            converter: .linear(multiplier: multiplierToBase)
        )
    }
}

/// Identifies whether a unit is predefined or user-defined.
public enum UnitIdentity: Hashable, Codable {
    case predefined(String)
    case custom(UUID)

    private enum CodingKeys: CodingKey {
        case type
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "pre":
            let value = try container.decode(String.self, forKey: .value)
            self = .predefined(value)
        case "custom":
            let rawUUID = try container.decode(UUID.self, forKey: .value)
            self = .custom(rawUUID)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unexpected unit identity type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .predefined(let value):
            try container.encode("pre", forKey: .type)
            try container.encode(value, forKey: .value)
        case .custom(let id):
            try container.encode("custom", forKey: .type)
            try container.encode(id, forKey: .value)
        }
    }

    public var rawValue: String {
        switch self {
        case .predefined(let value):
            return value
        case .custom(let id):
            return "custom." + id.uuidString
        }
    }
}

/// Basic preset that stores favourite conversions.
public struct ConversionPreset: Identifiable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public let category: MeasurementCategory
    public let fromUnit: UnitIdentity
    public let toUnit: UnitIdentity
    public var lastInputValue: Double?

    public init(id: UUID = UUID(), title: String, category: MeasurementCategory, fromUnit: UnitIdentity, toUnit: UnitIdentity, lastInputValue: Double? = nil) {
        self.id = id
        self.title = title
        self.category = category
        self.fromUnit = fromUnit
        self.toUnit = toUnit
        self.lastInputValue = lastInputValue
    }
}

/// Historic conversion entry kept for the last 20 operations.
public struct ConversionHistoryEntry: Identifiable, Codable {
    public let id: UUID
    public let timestamp: Date
    public let category: MeasurementCategory
    public let fromUnit: UnitIdentity
    public let toUnit: UnitIdentity
    public let inputValue: Double
    public let outputValue: Double
    public let precision: Int

    public init(id: UUID = UUID(), timestamp: Date = Date(), category: MeasurementCategory, fromUnit: UnitIdentity, toUnit: UnitIdentity, inputValue: Double, outputValue: Double, precision: Int) {
        self.id = id
        self.timestamp = timestamp
        self.category = category
        self.fromUnit = fromUnit
        self.toUnit = toUnit
        self.inputValue = inputValue
        self.outputValue = outputValue
        self.precision = precision
    }
}

/// Counter configuration and state.
public struct CounterItem: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var value: Double
    public var step: Double
    public var lowerBound: Double?
    public var upperBound: Double?
    public var hapticsEnabled: Bool

    public init(id: UUID = UUID(), name: String, value: Double = 0, step: Double = 1, lowerBound: Double? = nil, upperBound: Double? = nil, hapticsEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.value = value
        self.step = step
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.hapticsEnabled = hapticsEnabled
    }

    mutating func increment() {
        let next = value + step
        if let upperBound, next > upperBound {
            value = upperBound
        } else {
            value = next
        }
    }

    mutating func decrement() {
        let next = value - step
        if let lowerBound, next < lowerBound {
            value = lowerBound
        } else {
            value = next
        }
    }
}

/// Stopwatch snapshot for history export.
public struct StopwatchLog: Identifiable, Codable {
    public let id: UUID
    public let recordedAt: Date
    public let duration: TimeInterval

    public init(id: UUID = UUID(), recordedAt: Date = Date(), duration: TimeInterval) {
        self.id = id
        self.recordedAt = recordedAt
        self.duration = duration
    }
}

/// Global settings managed from the Settings tab.
public struct ToolkitSettings: Codable, Equatable {
    public struct UnitPreference: Codable, Equatable {
        public var from: UnitIdentity
        public var to: UnitIdentity

        public init(from: UnitIdentity, to: UnitIdentity) {
            self.from = from
            self.to = to
        }
    }

    public var precision: Int
    public var groupingSeparatorEnabled: Bool
    public var defaultUnits: [MeasurementCategory: UnitPreference]

    public init(precision: Int = 2, groupingSeparatorEnabled: Bool = true, defaultUnits: [MeasurementCategory: UnitPreference] = [:]) {
        self.precision = precision
        self.groupingSeparatorEnabled = groupingSeparatorEnabled
        self.defaultUnits = defaultUnits
    }
}

extension ToolkitSettings {
    static let `default` = ToolkitSettings()
}

/// Utility builders for formatting numeric values.
struct MeasurementFormatterFactory {
    static func formatter(settings: ToolkitSettings) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = settings.precision
        formatter.usesGroupingSeparator = settings.groupingSeparatorEnabled
        formatter.locale = Locale.current
        return formatter
    }
}
