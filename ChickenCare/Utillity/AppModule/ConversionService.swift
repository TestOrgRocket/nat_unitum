import Foundation

/// Performs bidirectional conversions between supported `UnitDefinition`s.
struct ConversionService {
    static func convert(value: Double, from: UnitDefinition, to: UnitDefinition) -> Double {
        guard from.category == to.category else { return .nan }
        let base = convertToBase(value: value, unit: from)
        return convertFromBase(baseValue: base, unit: to)
    }

    static func convertToBase(value: Double, unit: UnitDefinition) -> Double {
        switch unit.converter {
        case .linear(let multiplier):
            return value * multiplier
        case .affine(let scale, let offset):
            return value * scale + offset
        case .reciprocal(let multiplier):
            guard abs(value) > .ulpOfOne else { return .infinity }
            return multiplier / value
        case .temperature(let tempUnit):
            return temperatureToKelvin(value, unit: tempUnit)
        }
    }

    static func convertFromBase(baseValue: Double, unit: UnitDefinition) -> Double {
        switch unit.converter {
        case .linear(let multiplier):
            guard abs(multiplier) > .ulpOfOne else { return .nan }
            return baseValue / multiplier
        case .affine(let scale, let offset):
            guard abs(scale) > .ulpOfOne else { return .nan }
            return (baseValue - offset) / scale
        case .reciprocal(let multiplier):
            guard abs(baseValue) > .ulpOfOne else { return .infinity }
            return multiplier / baseValue
        case .temperature(let tempUnit):
            return temperatureFromKelvin(baseValue, unit: tempUnit)
        }
    }

    private static func temperatureToKelvin(_ value: Double, unit: TemperatureUnit) -> Double {
        switch unit {
        case .kelvin:
            return value
        case .celsius:
            return value + 273.15
        case .fahrenheit:
            return (value - 32) * 5.0 / 9.0 + 273.15
        }
    }

    private static func temperatureFromKelvin(_ kelvin: Double, unit: TemperatureUnit) -> Double {
        switch unit {
        case .kelvin:
            return kelvin
        case .celsius:
            return kelvin - 273.15
        case .fahrenheit:
            return (kelvin - 273.15) * 9.0 / 5.0 + 32
        }
    }
}
