import SwiftUI
import UIKit

struct CountersRootView: View {
    @EnvironmentObject private var state: MeasurementToolkitState
    @State private var isPresentingNewCounter = false

    var body: some View {
        List {
            Section(header: Text("Counters")) {
                if state.counters.isEmpty {
                    Text("Add a counter to start tracking.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(state.counters) { counter in
                        NavigationLink(destination: CounterDetailView(counter: counter)) {
                            CounterCard(counter: counter)
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
            }

            Section(header: Text("Stopwatch")) {
                NavigationLink(destination: StopwatchView()) {
                    Label("Stopwatch", systemImage: "timer")
                }
                if !state.stopwatchLogs.isEmpty {
                    ForEach(state.stopwatchLogs) { log in
                        VStack(alignment: .leading) {
                            Text(format(duration: log.duration))
                                .font(.headline)
                            Text(log.recordedAt, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    .navigationTitle("Counters")
        .toolbar(content: toolbarContent)
        .sheet(isPresented: $isPresentingNewCounter) {
            if #available(iOS 16.0, *) {
                NavigationStack { CounterEditorView(counter: CounterItem(name: "")) }
                    .presentationDetents([.medium, .large])
            } else {
                NavigationView { CounterEditorView(counter: CounterItem(name: "")) }
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
        Form {
            Section(header: Text("Overview")) {
                HStack {
                    TextField("Name", text: $counter.name)
                        .focused($focusedField, equals: .name)
                    Spacer()
                    Text(format(counter.value))
                        .font(.title2.weight(.bold))
                }

                HStack(spacing: 24) {
                    Button("- \(format(counter.step))") {
                        impact()
                        counter.decrement()
                        state.updateCounter(counter)
                    }
                    .buttonStyle(.bordered)

                    Button("+ \(format(counter.step))") {
                        impact()
                        counter.increment()
                        state.updateCounter(counter)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Button("Reset") {
                    counter.value = 0
                    state.updateCounter(counter)
                }
                .foregroundColor(.red)
            }

            Section(header: Text("Settings")) {
                Stepper(value: $counter.step, in: 0.1...1_000, step: 0.1) {
                    Text("Step: \(format(counter.step))")
                }
                .onChange(of: counter.step) { _ in state.updateCounter(counter) }

                Toggle("Haptics", isOn: Binding(
                    get: { counter.hapticsEnabled },
                    set: { newValue in
                        counter.hapticsEnabled = newValue
                        state.updateCounter(counter)
                    }
                ))

                TextField("Lower limit", text: Binding(
                    get: { text(from: counter.lowerBound) },
                    set: { counter.lowerBound = double(from: $0) }
                ))
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .lower)
                .onChange(of: counter.lowerBound) { _ in state.updateCounter(counter) }

                TextField("Upper limit", text: Binding(
                    get: { text(from: counter.upperBound) },
                    set: { counter.upperBound = double(from: $0) }
                ))
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .upper)
                .onChange(of: counter.upperBound) { _ in state.updateCounter(counter) }
            }
        }
    .navigationTitle(counter.name.isEmpty ? "Counter" : counter.name)
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
        Form {
            Section(header: Text("Counter")) {
                TextField("Name", text: $counter.name)
                Stepper(value: $counter.step, in: 0.1...1_000, step: 0.1) {
                    Text("Step: \(counter.step, specifier: "%.1f")")
                }
            }
        }
        .navigationTitle("New Counter")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    state.addCounter(counter)
                    dismiss()
                }
                .disabled(counter.name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
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
        VStack(spacing: 32) {
            Text(timeString)
                .font(.system(size: 56, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .padding(.top, 40)

            HStack(spacing: 24) {
                Button(isRunning ? "Pause" : "Start", action: toggle)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                Button("Reset", action: reset)
                    .buttonStyle(.bordered)
                    .disabled(!isRunning && elapsed == 0)
            }

            if elapsed > 0 {
                Button("Save to Log") {
                    state.appendStopwatchLog(duration: elapsed)
                }
                .buttonStyle(.bordered)

                if #available(iOS 16.0, *) {
                    ShareLink(item: exportText) {
                        Label("Export to Notes", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button {
                        exportLegacy()
                    } label: {
                        Label("Export to Notes", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                }
            }

            Spacer()
        }
        .onReceive(timer) { _ in tick() }
    .navigationTitle("Stopwatch")
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
