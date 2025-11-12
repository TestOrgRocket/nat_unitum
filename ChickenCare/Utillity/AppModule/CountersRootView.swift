import SwiftUI
import UIKit

struct CountersRootView: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    @State private var isPresentingNewCounter = false

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

            ScrollView {
                VStack(spacing: 28) {
                    HStack {
                        Text("Counters")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { isPresentingNewCounter = true }) {
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundColor(Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0))
                                .padding(10)
                                .background(Color.white.opacity(0.85))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.10), radius: 3, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 18) {
                        Text("COUNTERS")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.leading, 6)

                        if state.counters.isEmpty {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.85))
                                .frame(height: 54)
                                .overlay(
                                    Text("Add a counter to start tracking.")
                                        .foregroundColor(.secondary)
                                        .font(.body)
                                )
                                .padding(.horizontal, 8)
                        } else {
                            VStack(spacing: 14) {
                                ForEach(state.counters) { counter in
                                    NavigationLink(destination: CounterDetailView(counter: counter)) {
                                        HStack(spacing: 16) {
                                            Image(systemName: "number")
                                                .font(.title2)
                                                .foregroundColor(Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0))
                                                .padding(8)
                                                .background(Color.white.opacity(0.25))
                                                .clipShape(Circle())
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(counter.name.isEmpty ? "Untitled" : counter.name)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Text("Step: \(MeasurementFormatterFactory.formatter(settings: state.settings).string(from: NSNumber(value: counter.step)) ?? String(counter.step))")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Text(MeasurementFormatterFactory.formatter(settings: state.settings).string(from: NSNumber(value: counter.value)) ?? String(counter.value))
                                                .font(.title3.weight(.bold))
                                                .foregroundColor(.primary)
                                        }
                                        .padding(16)
                                        .background(Color.white.opacity(0.85))
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            state.removeCounter(counter)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                    .padding(.horizontal, 10)

                    VStack(alignment: .leading, spacing: 18) {
                        Text("STOPWATCH")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.leading, 6)

                        NavigationLink(destination: StopwatchView()) {
                            HStack(spacing: 14) {
                                Image(systemName: "timer")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0))
                                    .padding(8)
                                    .background(Color.white.opacity(0.25))
                                    .clipShape(Circle())
                                Text("Stopwatch")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.85))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal, 2)

                        if !state.stopwatchLogs.isEmpty {
                            VStack(spacing: 10) {
                                ForEach(state.stopwatchLogs) { log in
                                    HStack {
                                        Image(systemName: "clock")
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                        Text(format(duration: log.duration))
                                            .font(.body.weight(.semibold))
                                        Spacer()
                                        Text(log.recordedAt, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.65))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.top, 2)
                        }
                    }
                    .padding(.horizontal, 10)

                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
        }
        .gradientNavigationTitle("")
        .modifier(HideNavBarToolbar())
        .sheet(isPresented: $isPresentingNewCounter) {
            if #available(iOS 16.0, *) {
                NavigationStack { CounterEditorView(counter: CounterItem(name: "")) }
                    .presentationDetents([.medium, .large])
            } else {
                NavigationView { CounterEditorView(counter: CounterItem(name: "")) }
            }
        }
    }

// Helper modifier for toolbar hiding compatibility
struct HideNavBarToolbar: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.toolbar(.hidden, for: .navigationBar)
        } else {
            content
        }
    }
}

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            addButton
        }
    }

    private var addButton: some View {
        Button {
            isPresentingNewCounter = true
        } label: {
            Image(systemName: "plus")
        }
    .accessibilityLabel("Add counter")
    }

    private func format(duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? "—"
    }
}

private struct CounterCard: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    let counter: CounterItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(counter.name.isEmpty ? "Untitled" : counter.name)
                    .font(.headline)
                Spacer()
                Text(format(counter.value))
                    .font(.title3.weight(.semibold))
            }

            HStack(spacing: 16) {
                Button {
                    impact()
                    decrement()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                }

                Button {
                    impact()
                    increment()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }

                Spacer()

                Text("Step: \(format(counter.step))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    private func impact() {
        guard counter.hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func increment() {
        var updated = counter
        updated.increment()
        state.updateCounter(updated)
    }

    private func decrement() {
        var updated = counter
        updated.decrement()
        state.updateCounter(updated)
    }

    private func format(_ value: Double) -> String {
        MeasurementFormatterFactory.formatter(settings: state.settings).string(from: NSNumber(value: value)) ?? String(value)
    }
}

private struct CounterDetailView: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    @State private var counter: CounterItem
    @FocusState private var focusedField: Field?

    enum Field {
        case name
        case step
        case lower
        case upper
    }

    init(counter: CounterItem) {
        _counter = State(initialValue: counter)
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
            
            ScrollView {
                VStack(spacing: 24) {
                    // Overview card
                    VStack(spacing: 12) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("OVERVIEW")
                                    .font(.headline.weight(.semibold))
                                    .textCase(.uppercase)
                                    // stronger cyan to increase contrast against the semi-opaque white card
                                    .foregroundColor(Color(red: 40.0/255.0, green: 115.0/255.0, blue: 150.0/255.0))
                                    .apply {
                                        if #available(iOS 16.0, *) {
                                            $0.kerning(0.6)
                                        } else {
                                            $0
                                        }
                                    }
                                    .shadow(color: Color.black.opacity(0.06), radius: 0.6, x: 0, y: 0)
                                TextField("Name", text: $counter.name)
                                    .focused($focusedField, equals: .name)
                                    .font(.title3.weight(.semibold))
                            }
                            Spacer()
                            Text(format(counter.value))
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                        }

                        HStack(spacing: 14) {
                            // Pill-style step buttons to improve affordance and visual structure
                            Button(action: {
                                impact()
                                counter.decrement()
                                state.updateCounter(counter)
                            }) {
                                Text("- \(format(counter.step))")
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(Color(red: 40/255, green: 115/255, blue: 150/255))
                                    .frame(minWidth: 72)
                                    .padding(.vertical, 10)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 40/255, green: 115/255, blue: 150/255).opacity(0.12), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                            }

                            Button(action: {
                                impact()
                                counter.increment()
                                state.updateCounter(counter)
                            }) {
                                Text("+ \(format(counter.step))")
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 72)
                                    .padding(.vertical, 10)
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [Color(red: 0/255, green: 180/255, blue: 216/255), Color(red: 72/255, green: 202/255, blue: 228/255)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: Color(red: 0/255, green: 180/255, blue: 216/255).opacity(0.18), radius: 6, x: 0, y: 2)
                            }

                            Spacer()

                            Button(action: {
                                counter.value = 0
                                state.updateCounter(counter)
                            }) {
                                Text("Reset")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(18)
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)

                    // Settings card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SETTINGS")
                            .font(.headline.weight(.semibold))
                            .textCase(.uppercase)
                            // stronger cyan for better readability on the white card
                            .foregroundColor(Color(red: 40.0/255.0, green: 115.0/255.0, blue: 150.0/255.0))
                            .apply {
                                if #available(iOS 16.0, *) {
                                    $0.kerning(0.6)
                                } else {
                                    $0
                                }
                            }
                            .shadow(color: Color.black.opacity(0.06), radius: 0.6, x: 0, y: 0)

                        HStack(spacing: 12) {
                            Text("Step:")
                                .font(.body.weight(.medium))
                            Text(format(counter.step))
                                .font(.body.weight(.bold))
                                .foregroundColor(Color(red: 0/255, green: 180/255, blue: 216/255))
                            Spacer()
                            HStack(spacing: 8) {
                                Button(action: {
                                    let new = (counter.step - 0.1)
                                    counter.step = new >= 0.1 ? (round(new * 10) / 10) : 0.1
                                    state.updateCounter(counter)
                                }) {
                                    Image(systemName: "minus")
                                        .font(.headline)
                                        .foregroundColor(Color(red: 40/255, green: 115/255, blue: 150/255))
                                        .frame(width: 40, height: 36)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10).stroke(Color(red: 40/255, green: 115/255, blue: 150/255).opacity(0.08), lineWidth: 1)
                                        )
                                }
                                Button(action: {
                                    let new = (counter.step + 0.1)
                                    counter.step = new <= 1000 ? (round(new * 10) / 10) : 1000
                                    state.updateCounter(counter)
                                }) {
                                    Image(systemName: "plus")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 36)
                                        .background(Color(red: 0/255, green: 180/255, blue: 216/255))
                                        .cornerRadius(10)
                                        .shadow(color: Color(red: 0/255, green: 180/255, blue: 216/255).opacity(0.18), radius: 4, x: 0, y: 1)
                                }
                            }
                        }

                        Toggle(isOn: Binding(get: { counter.hapticsEnabled }, set: { new in counter.hapticsEnabled = new; state.updateCounter(counter) })) {
                            Text("Haptics")
                        }

                        TextField("Lower limit", text: Binding(
                            get: { text(from: counter.lowerBound) },
                            set: { counter.lowerBound = double(from: $0); state.updateCounter(counter) }
                        ))
                        .keyboardType(.decimalPad)

                        TextField("Upper limit", text: Binding(
                            get: { text(from: counter.upperBound) },
                            set: { counter.upperBound = double(from: $0); state.updateCounter(counter) }
                        ))
                        .keyboardType(.decimalPad)
                    }
                    .padding(18)
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
    .gradientNavigationTitle(counter.name.isEmpty ? "Counter" : counter.name)
        .onDisappear { state.updateCounter(counter) }
    }

    private func text(from value: Double?) -> String {
        guard let value else { return "" }
        return format(value)
    }

    private func double(from text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }

    private func format(_ value: Double) -> String {
        let formatter = MeasurementFormatterFactory.formatter(settings: state.settings)
        formatter.maximumFractionDigits = 4
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    private func impact() {
        guard counter.hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }
}

private struct CounterEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var state: MeasurementToolkitState
    @State private var counter: CounterItem

    init(counter: CounterItem) {
        _counter = State(initialValue: counter)
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
                Spacer(minLength: 18)
                VStack(alignment: .leading, spacing: 18) {
                    Text("NEW COUNTER")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.leading, 6)

                    VStack(spacing: 18) {
                        TextField("Name", text: $counter.name)
                            .font(.title3.weight(.medium))
                            .padding(14)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0).opacity(0.18), lineWidth: 1.5)
                            )

                        HStack(spacing: 12) {
                            Text("Step:")
                                .font(.body.weight(.medium))
                            Text(String(format: "%.1f", counter.step))
                                .font(.body.weight(.bold))
                                .foregroundColor(Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0))
                                .frame(width: 48, alignment: .trailing)
                            Spacer()
                            HStack(spacing: 8) {
                                Button(action: {
                                    let new = (counter.step - 0.1)
                                    counter.step = new >= 0.1 ? (round(new * 10) / 10) : 0.1
                                }) {
                                    Image(systemName: "minus")
                                        .font(.body.weight(.semibold))
                                        .frame(width: 36, height: 32)
                                        .background(Color.white.opacity(0.9))
                                        .cornerRadius(8)
                                }

                                Button(action: {
                                    let new = (counter.step + 0.1)
                                    counter.step = new <= 1000 ? (round(new * 10) / 10) : 1000
                                }) {
                                    Image(systemName: "plus")
                                        .font(.body.weight(.semibold))
                                        .frame(width: 36, height: 32)
                                        .background(Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 6)
                    }
                    .padding(18)
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                }
                .padding(.horizontal, 16)

                Spacer()

                HStack(spacing: 18) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.body.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.gray.opacity(0.35))
                            .cornerRadius(14)
                    }
                    Button(action: {
                        state.addCounter(counter)
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.body.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0),
                                        Color(red: 72.0 / 255.0, green: 202.0 / 255.0, blue: 228.0 / 255.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: Color.black.opacity(0.10), radius: 4, x: 0, y: 2)
                    }
                    .disabled(counter.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
            }
        }
        .gradientNavigationTitle("New Counter")
    }
}

private struct StopwatchView: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    @State private var isRunning = false
    @State private var startDate: Date?
    @State private var elapsed: TimeInterval = 0
    @State private var accumulated: TimeInterval = 0
    @Environment(\.dismiss) private var dismiss
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

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

            VStack(spacing: 36) {
                Spacer(minLength: 32)
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0),
                                    Color(red: 72.0 / 255.0, green: 202.0 / 255.0, blue: 228.0 / 255.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 6
                        )
                        .shadow(color: Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0).opacity(0.25), radius: 18, x: 0, y: 0)
                        .frame(width: 200, height: 200)
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 188, height: 188)
                    Text(timeString)
                        .font(.system(size: 56, weight: .medium, design: .monospaced))
                        .monospacedDigit()
                        .foregroundColor(Color(red: 40.0/255.0, green: 115.0/255.0, blue: 150.0/255.0))
                }
                .padding(.top, 16)

                HStack(spacing: 24) {
                    Button(isRunning ? "Pause" : "Start", action: toggle)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 110, height: 48)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0),
                                    Color(red: 72.0 / 255.0, green: 202.0 / 255.0, blue: 228.0 / 255.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: Color.black.opacity(0.10), radius: 4, x: 0, y: 2)

                    Button("Reset", action: reset)
                        .font(.title3.bold())
                        .foregroundColor(isRunning || elapsed > 0 ? Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0) : .gray)
                        .frame(width: 110, height: 48)
                        .background(Color.white.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                        .disabled(!isRunning && elapsed == 0)
                }

                if elapsed > 0 {
                    Button(action: { state.appendStopwatchLog(duration: elapsed) }) {
                        Label("Save to Log", systemImage: "plus.rectangle.on.rectangle")
                            .font(.body.bold())
                            .foregroundColor(Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.85))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                    }

                    if #available(iOS 16.0, *) {
                        ShareLink(item: exportText) {
                            Label("Export to Notes", systemImage: "square.and.arrow.up")
                                .font(.body.bold())
                                .foregroundColor(Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.85))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                        }
                    } else {
                        Button {
                            exportLegacy()
                        } label: {
                            Label("Export to Notes", systemImage: "square.and.arrow.up")
                                .font(.body.bold())
                                .foregroundColor(Color(red: 0.0 / 255.0, green: 180.0 / 255.0, blue: 216.0 / 255.0))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.85))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                        }
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .onReceive(timer) { _ in tick() }
        .gradientNavigationTitle("Stopwatch")
    }

    private func toggle() {
        if isRunning {
            accumulated += Date().timeIntervalSince(startDate ?? Date())
            startDate = nil
            isRunning = false
        } else {
            startDate = Date()
            isRunning = true
        }
        updateElapsed()
    }

    private func reset() {
        elapsed = 0
        accumulated = 0
        startDate = nil
        isRunning = false
    }

    private func tick() {
        guard isRunning else {
            updateElapsed()
            return
        }
        updateElapsed()
    }

    private var timeString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: elapsed) ?? "00:00"
    }

    private func updateElapsed() {
        if isRunning, let startDate {
            elapsed = accumulated + Date().timeIntervalSince(startDate)
        } else {
            elapsed = accumulated
        }
    }

    private var exportText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Stopwatch (\(formatter.string(from: Date()))) — \(String(format: "%.2f", elapsed)) sec"
    }

    private func exportLegacy() {
        UIPasteboard.general.string = exportText
    }
}

// MARK: - View Extension for Conditional Modifiers
extension View {
    @ViewBuilder
    func apply<Content: View>(@ViewBuilder transform: (Self) -> Content) -> some View {
        transform(self)
    }
    
    func gradientNavigationTitle(_ title: String) -> some View {
        if #available(iOS 16.0, *) {
            return AnyView(
                self.navigationTitle(title)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbarBackground(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 4.0 / 255.0, green: 113.0 / 255.0, blue: 143.0 / 255.0),
                                Color(red: 0.0 / 255.0, green: 140.0 / 255.0, blue: 180.0 / 255.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        for: .navigationBar
                    )
                    .toolbarBackground(.visible, for: .navigationBar)
            )
        } else {
            return AnyView(
                self.navigationTitle(title)
                    .navigationBarTitleDisplayMode(.automatic)
            )
        }
    }
}
