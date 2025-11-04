import SwiftUI

struct ReferenceRootView: View {
    private let prefixes: [(symbol: String, name: String, factor: String)] = [
        ("Y", "Yotta", "10²⁴"),
        ("Z", "Zetta", "10²¹"),
        ("E", "Exa", "10¹⁸"),
        ("P", "Peta", "10¹⁵"),
        ("T", "Tera", "10¹²"),
        ("G", "Giga", "10⁹"),
        ("M", "Mega", "10⁶"),
        ("k", "Kilo", "10³"),
        ("h", "Hecto", "10²"),
        ("da", "Deca", "10¹"),
        ("d", "Deci", "10⁻¹"),
        ("c", "Centi", "10⁻²"),
        ("m", "Milli", "10⁻³"),
        ("µ", "Micro", "10⁻⁶"),
        ("n", "Nano", "10⁻⁹"),
        ("p", "Pico", "10⁻¹²"),
        ("f", "Femto", "10⁻¹⁵"),
        ("a", "Atto", "10⁻¹⁸"),
        ("z", "Zepto", "10⁻²¹"),
        ("y", "Yocto", "10⁻²⁴")
    ]

    private let baseUnits: [(quantity: String, symbol: String, unit: String)] = [
        ("Length", "m", "meter"),
        ("Mass", "kg", "kilogram"),
        ("Time", "s", "second"),
        ("Electric current", "A", "ampere"),
        ("Temperature", "K", "kelvin"),
        ("Amount of substance", "mol", "mole"),
        ("Luminous intensity", "cd", "candela"),
        ("Information", "bit", "bit")
    ]

    private let constants: [(name: String, value: String, notes: String)] = [
        ("Standard gravity", "g = 9.80665 m/s²", "Used for weight calculations"),
        ("Speed of light", "c = 299 792 458 m/s", "Fundamental physical constant"),
        ("Planck constant", "h = 6.62607015×10⁻³⁴ J·s", "Converts frequency to energy"),
        ("Mains frequency", "f = 50/60 Hz", "Used for electrical system calculations"),
        ("Universal gas constant", "R = 8.314462618 J/(mol·K)", "Thermodynamics and chemistry"),
        ("Earth radius", "Rₑ ≈ 6 371 km", "Navigation and geodesy")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ReferenceSection(title: "SI prefixes") {
                    ReferenceTable(headers: ["Prefix", "Name", "Multiplier"], rows: prefixes.map { [$0.symbol, $0.name, $0.factor] })
                }

                ReferenceSection(title: "Base quantities") {
                    ReferenceTable(headers: ["Quantity", "Symbol", "Unit"], rows: baseUnits.map { [$0.quantity, $0.symbol, $0.unit] })
                }

                ReferenceSection(title: "Constants") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(constants, id: \.name) { constant in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(constant.name)
                                    .font(.headline)
                                Text(constant.value)
                                    .font(.body.weight(.semibold))
                                Text(constant.notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(uiColor: .secondarySystemBackground)))
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Reference")
    }
}

private struct ReferenceSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.weight(.semibold))
            content
        }
    }
}

private struct ReferenceTable: View {
    let headers: [String]
    let rows: [[String]]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(Array(headers.enumerated()), id: \.offset) { _, header in
                    Text(header)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(12)
            .background(Color(uiColor: .tertiarySystemFill))

            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, value in
                        Text(value)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 12)
                .background(Color(uiColor: .systemBackground))
                Divider()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(uiColor: .separator), lineWidth: 0.5)
        )
    }
}
