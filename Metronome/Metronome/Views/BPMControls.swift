//
//  BPMControls.swift
//  Metronome
//

import SwiftUI

struct BPMControls: View {
    @Environment(MetronomeEngine.self) private var engine

    @State private var holdTimer: Timer?

    var body: some View {
        HStack(spacing: 40) {
            incrementButton(delta: -1, systemName: "minus")
            incrementButton(delta: 1, systemName: "plus")
        }
    }

    // MARK: - Increment Button

    private func incrementButton(delta: Double, systemName: String) -> some View {
        Button {
            engine.setBPM(engine.bpm + delta)
        } label: {
            Image(systemName: systemName)
                .font(.title2)
                .padding(16)
        }
        .glassEffect(.regular.interactive())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    startHold(delta: delta)
                }
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onEnded { _ in
                    stopHold()
                }
        )
    }

    // MARK: - Hold Logic

    private func startHold(delta: Double) {
        stopHold()
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            engine.setBPM(engine.bpm + delta)
        }
    }

    private func stopHold() {
        holdTimer?.invalidate()
        holdTimer = nil
    }
}

#Preview {
    BPMControls()
        .environment(MetronomeEngine())
}
