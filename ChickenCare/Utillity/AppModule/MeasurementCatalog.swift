import Foundation

/// Collection of canonical unit definitions backed by coefficient based conversion.
struct MeasurementCatalog {
    static let shared = MeasurementCatalog()

    private let predefinedUnits: [MeasurementCategory: [UnitDefinition]]

    private init() {
        predefinedUnits = [
            .length: [
                UnitDefinition(id: "length.meter", category: .length, name: "Meter", symbol: "m", converter: .linear(multiplier: 1), isSystemUnit: true),
                UnitDefinition(id: "length.kilometer", category: .length, name: "Kilometer", symbol: "km", converter: .linear(multiplier: 1_000)),
                UnitDefinition(id: "length.centimeter", category: .length, name: "Centimeter", symbol: "cm", converter: .linear(multiplier: 0.01)),
                UnitDefinition(id: "length.millimeter", category: .length, name: "Millimeter", symbol: "mm", converter: .linear(multiplier: 0.001)),
                UnitDefinition(id: "length.micrometer", category: .length, name: "Micrometer", symbol: "µm", converter: .linear(multiplier: 0.000001)),
                UnitDefinition(id: "length.nanometer", category: .length, name: "Nanometer", symbol: "nm", converter: .linear(multiplier: 0.000000001)),
                UnitDefinition(id: "length.mile", category: .length, name: "Mile", symbol: "mi", converter: .linear(multiplier: 1_609.344)),
                UnitDefinition(id: "length.yard", category: .length, name: "Yard", symbol: "yd", converter: .linear(multiplier: 0.9144)),
                UnitDefinition(id: "length.foot", category: .length, name: "Foot", symbol: "ft", converter: .linear(multiplier: 0.3048)),
                UnitDefinition(id: "length.inch", category: .length, name: "Inch", symbol: "in", converter: .linear(multiplier: 0.0254)),
                UnitDefinition(id: "length.nauticalMile", category: .length, name: "Nautical Mile", symbol: "NM", converter: .linear(multiplier: 1_852)),
                UnitDefinition(id: "length.lightYear", category: .length, name: "Light Year", symbol: "ly", converter: .linear(multiplier: 9_460_730_472_580_800))
            ],
            .mass: [
                UnitDefinition(id: "mass.kilogram", category: .mass, name: "Kilogram", symbol: "kg", converter: .linear(multiplier: 1), isSystemUnit: true),
                UnitDefinition(id: "mass.gram", category: .mass, name: "Gram", symbol: "g", converter: .linear(multiplier: 0.001)),
                UnitDefinition(id: "mass.milligram", category: .mass, name: "Milligram", symbol: "mg", converter: .linear(multiplier: 0.000001)),
                UnitDefinition(id: "mass.microgram", category: .mass, name: "Microgram", symbol: "µg", converter: .linear(multiplier: 0.000000001)),
                UnitDefinition(id: "mass.metricTon", category: .mass, name: "Metric Ton", symbol: "t", converter: .linear(multiplier: 1_000)),
                UnitDefinition(id: "mass.pound", category: .mass, name: "Pound", symbol: "lb", converter: .linear(multiplier: 0.45359237)),
                UnitDefinition(id: "mass.ounce", category: .mass, name: "Ounce", symbol: "oz", converter: .linear(multiplier: 0.028349523125)),
                UnitDefinition(id: "mass.stone", category: .mass, name: "Stone", symbol: "st", converter: .linear(multiplier: 6.35029318))
            ],
            .volume: [
                UnitDefinition(id: "volume.cubicMeter", category: .volume, name: "Cubic Meter", symbol: "m³", converter: .linear(multiplier: 1), isSystemUnit: true),
                UnitDefinition(id: "volume.liter", category: .volume, name: "Liter", symbol: "L", converter: .linear(multiplier: 0.001)),
                UnitDefinition(id: "volume.milliliter", category: .volume, name: "Milliliter", symbol: "mL", converter: .linear(multiplier: 0.000001)),
                UnitDefinition(id: "volume.usGallon", category: .volume, name: "US Gallon", symbol: "gal", converter: .linear(multiplier: 0.003785411784)),
                UnitDefinition(id: "volume.usQuart", category: .volume, name: "US Quart", symbol: "qt", converter: .linear(multiplier: 0.000946352946)),
                UnitDefinition(id: "volume.usPint", category: .volume, name: "US Pint", symbol: "pt", converter: .linear(multiplier: 0.000473176473)),
                UnitDefinition(id: "volume.cubicFoot", category: .volume, name: "Cubic Foot", symbol: "ft³", converter: .linear(multiplier: 0.028316846592)),
                UnitDefinition(id: "volume.cubicInch", category: .volume, name: "Cubic Inch", symbol: "in³", converter: .linear(multiplier: 0.000016387064))
            ],
            .area: [
                UnitDefinition(id: "area.squareMeter", category: .area, name: "Square Meter", symbol: "m²", converter: .linear(multiplier: 1), isSystemUnit: true),
                UnitDefinition(id: "area.squareKilometer", category: .area, name: "Square Kilometer", symbol: "km²", converter: .linear(multiplier: 1_000_000)),
                UnitDefinition(id: "area.squareCentimeter", category: .area, name: "Square Centimeter", symbol: "cm²", converter: .linear(multiplier: 0.0001)),
                UnitDefinition(id: "area.squareMillimeter", category: .area, name: "Square Millimeter", symbol: "mm²", converter: .linear(multiplier: 0.000001)),
                UnitDefinition(id: "area.hectare", category: .area, name: "Hectare", symbol: "ha", converter: .linear(multiplier: 10_000)),
                UnitDefinition(id: "area.are", category: .area, name: "Are", symbol: "a", converter: .linear(multiplier: 100)),
                UnitDefinition(id: "area.squareMile", category: .area, name: "Square Mile", symbol: "mi²", converter: .linear(multiplier: 2_589_988.110336)),
                UnitDefinition(id: "area.squareYard", category: .area, name: "Square Yard", symbol: "yd²", converter: .linear(multiplier: 0.83612736)),
                UnitDefinition(id: "area.squareFoot", category: .area, name: "Square Foot", symbol: "ft²", converter: .linear(multiplier: 0.09290304)),
                UnitDefinition(id: "area.squareInch", category: .area, name: "Square Inch", symbol: "in²", converter: .linear(multiplier: 0.00064516)),
                UnitDefinition(id: "area.acre", category: .area, name: "Acre", symbol: "ac", converter: .linear(multiplier: 4_046.8564224))
            ],
            .speed: [
                UnitDefinition(id: "speed.meterPerSecond", category: .speed, name: "Meter per Second", symbol: "m/s", converter: .linear(multiplier: 1), isSystemUnit: true),
                UnitDefinition(id: "speed.kilometerPerHour", category: .speed, name: "Kilometer per Hour", symbol: "km/h", converter: .linear(multiplier: 0.2777777778)),
                UnitDefinition(id: "speed.milePerHour", category: .speed, name: "Mile per Hour", symbol: "mph", converter: .linear(multiplier: 0.44704)),
                UnitDefinition(id: "speed.knot", category: .speed, name: "Knot", symbol: "kn", converter: .linear(multiplier: 0.5144444444)),
                UnitDefinition(id: "speed.footPerSecond", category: .speed, name: "Foot per Second", symbol: "ft/s", converter: .linear(multiplier: 0.3048)),
                UnitDefinition(id: "speed.mach", category: .speed, name: "Mach (sea level)", symbol: "Ma", converter: .linear(multiplier: 340.29))
            ],
            .temperature: [
                UnitDefinition(id: "temperature.kelvin", category: .temperature, name: "Kelvin", symbol: "K", converter: .temperature(.kelvin), isSystemUnit: true),
                UnitDefinition(id: "temperature.celsius", category: .temperature, name: "Celsius", symbol: "°C", converter: .temperature(.celsius)),
                UnitDefinition(id: "temperature.fahrenheit", category: .temperature, name: "Fahrenheit", symbol: "°F", converter: .temperature(.fahrenheit))
            ],
            .pressure: [
                UnitDefinition(id: "pressure.pascal", category: .pressure, name: "Pascal", symbol: "Pa", converter: .linear(multiplier: 1), isSystemUnit: true),
                UnitDefinition(id: "pressure.kilopascal", category: .pressure, name: "Kilopascal", symbol: "kPa", converter: .linear(multiplier: 1_000)),
                UnitDefinition(id: "pressure.bar", category: .pressure, name: "Bar", symbol: "bar", converter: .linear(multiplier: 100_000)),
                UnitDefinition(id: "pressure.atmosphere", category: .pressure, name: "Standard Atmosphere", symbol: "atm", converter: .linear(multiplier: 101_325)),
                UnitDefinition(id: "pressure.mmHg", category: .pressure, name: "Millimeter of Mercury", symbol: "mmHg", converter: .linear(multiplier: 133.322)),
                UnitDefinition(id: "pressure.psi", category: .pressure, name: "Pound per Square Inch", symbol: "psi", converter: .linear(multiplier: 6_894.757293168))
            ],
            .energy: [
                UnitDefinition(id: "energy.joule", category: .energy, name: "Joule", symbol: "J", converter: .linear(multiplier: 1), isSystemUnit: true),
                UnitDefinition(id: "energy.kilojoule", category: .energy, name: "Kilojoule", symbol: "kJ", converter: .linear(multiplier: 1_000)),
                UnitDefinition(id: "energy.calorie", category: .energy, name: "Calorie", symbol: "cal", converter: .linear(multiplier: 4.184)),
                UnitDefinition(id: "energy.kilocalorie", category: .energy, name: "Kilocalorie", symbol: "kcal", converter: .linear(multiplier: 4_184)),
                UnitDefinition(id: "energy.wattHour", category: .energy, name: "Watt Hour", symbol: "Wh", converter: .linear(multiplier: 3_600)),
                UnitDefinition(id: "energy.kilowattHour", category: .energy, name: "Kilowatt Hour", symbol: "kWh", converter: .linear(multiplier: 3_600_000)),
                UnitDefinition(id: "energy.electronVolt", category: .energy, name: "Electron Volt", symbol: "eV", converter: .linear(multiplier: 1.602176634e-19))
            ],
            .force: [
                UnitDefinition(id: "force.newton", category: .force, name: "Newton", symbol: "N", converter: .linear(multiplier: 1), isSystemUnit: true),
                UnitDefinition(id: "force.kilonewton", category: .force, name: "Kilonewton", symbol: "kN", converter: .linear(multiplier: 1_000)),
                UnitDefinition(id: "force.poundForce", category: .force, name: "Pound-force", symbol: "lbf", converter: .linear(multiplier: 4.4482216152605)),
                UnitDefinition(id: "force.kilogramForce", category: .force, name: "Kilogram-force", symbol: "kgf", converter: .linear(multiplier: 9.80665)),
                UnitDefinition(id: "force.dyne", category: .force, name: "Dyne", symbol: "dyn", converter: .linear(multiplier: 0.00001))
            ],
            .time: [
                UnitDefinition(id: "time.second", category: .time, name: "Second", symbol: "s", converter: .linear(multiplier: 1), isSystemUnit: true),
                UnitDefinition(id: "time.millisecond", category: .time, name: "Millisecond", symbol: "ms", converter: .linear(multiplier: 0.001)),
                UnitDefinition(id: "time.minute", category: .time, name: "Minute", symbol: "min", converter: .linear(multiplier: 60)),
                UnitDefinition(id: "time.hour", category: .time, name: "Hour", symbol: "h", converter: .linear(multiplier: 3_600)),
                UnitDefinition(id: "time.day", category: .time, name: "Day", symbol: "d", converter: .linear(multiplier: 86_400)),
                UnitDefinition(id: "time.week", category: .time, name: "Week", symbol: "wk", converter: .linear(multiplier: 604_800)),
                UnitDefinition(id: "time.month", category: .time, name: "Month", symbol: "mo", converter: .linear(multiplier: 2_629_746)),
                UnitDefinition(id: "time.year", category: .time, name: "Year", symbol: "yr", converter: .linear(multiplier: 31_556_952))
            ],
            .angle: [
                UnitDefinition(id: "angle.radian", category: .angle, name: "Radian", symbol: "rad", converter: .linear(multiplier: 1), isSystemUnit: true),
                UnitDefinition(id: "angle.degree", category: .angle, name: "Degree", symbol: "°", converter: .linear(multiplier: .pi / 180)),
                UnitDefinition(id: "angle.gradian", category: .angle, name: "Gradian", symbol: "grad", converter: .linear(multiplier: .pi / 200)),
                UnitDefinition(id: "angle.arcminute", category: .angle, name: "Arcminute", symbol: "′", converter: .linear(multiplier: .pi / 10_800)),
                UnitDefinition(id: "angle.arcsecond", category: .angle, name: "Arcsecond", symbol: "″", converter: .linear(multiplier: .pi / 648_000)),
                UnitDefinition(id: "angle.turn", category: .angle, name: "Turn", symbol: "turn", converter: .linear(multiplier: 2 * .pi))
            ],
            .fuelConsumption: [
                UnitDefinition(id: "fuel.kilometerPerLiter", category: .fuelConsumption, name: "Kilometer per Liter", symbol: "km/L", converter: .linear(multiplier: 1), isSystemUnit: true),
                UnitDefinition(id: "fuel.literPer100Km", category: .fuelConsumption, name: "Liter per 100 km", symbol: "L/100km", converter: .reciprocal(multiplier: 100)),
                UnitDefinition(id: "fuel.milePerGallonUS", category: .fuelConsumption, name: "Mile per Gallon (US)", symbol: "mpg", converter: .linear(multiplier: 1.609344 / 3.785411784)),
                UnitDefinition(id: "fuel.milePerGallonUK", category: .fuelConsumption, name: "Mile per Gallon (UK)", symbol: "mpg(UK)", converter: .linear(multiplier: 1.609344 / 4.54609)),
                UnitDefinition(id: "fuel.literPerKilometer", category: .fuelConsumption, name: "Liter per Kilometer", symbol: "L/km", converter: .reciprocal(multiplier: 1))
            ]
        ]
    }

    func units(for category: MeasurementCategory, customUnits: [CustomUnit]) -> [UnitDefinition] {
        let custom = customUnits
            .filter { $0.category == category }
            .map { $0.definition }
        let predefined = predefinedUnits[category] ?? []
        return (predefined + custom).sorted { lhs, rhs in
            if lhs.isSystemUnit && !rhs.isSystemUnit { return true }
            if !lhs.isSystemUnit && rhs.isSystemUnit { return false }
            return lhs.name < rhs.name
        }
    }

    func unitDefinition(for identity: UnitIdentity, customUnits: [CustomUnit]) -> UnitDefinition? {
        switch identity {
        case .predefined(let id):
            return predefinedUnits.values.flatMap { $0 }.first { $0.id == id }
        case .custom(let customID):
            return customUnits.first { $0.id == customID }?.definition
        }
    }

    func baseUnit(for category: MeasurementCategory) -> UnitDefinition? {
        (predefinedUnits[category] ?? []).first { $0.isSystemUnit }
    }

    func hasSymbolConflict(_ symbol: String, category: MeasurementCategory, customUnits: [CustomUnit], excluding excludedID: UUID? = nil) -> Bool {
        let normalized = symbol.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let predefinedConflict = (predefinedUnits[category] ?? []).contains { $0.symbol.lowercased() == normalized }
        let customConflict = customUnits.contains {
            $0.category == category && $0.symbol.lowercased() == normalized && $0.id != excludedID
        }
        return predefinedConflict || customConflict
    }
}
