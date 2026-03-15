//
//  TapTempoButton.swift
//  Metronome
//

import SwiftUI

struct TapTempoButton: View {
    @Environment(MetronomeEngine.self) private var engine

    @State private var tapTimes: [Date] = []
    @State private var lastTapTime: Date?

    var body: some View {
        Button {
            handleTap()
        } label: {
            Text("Tap")
                .font(.title2)
                .frame(minWidth: 60, minHeight: 60)
        }
        .buttonStyle(.bordered)
    }

    // MARK: - Tap Logic

    private func handleTap() {
        let now = Date()

        if let last = lastTapTime, now.timeIntervalSince(last) < 3.0 {
            tapTimes.append(now)
            if tapTimes.count > 4 { tapTimes.removeFirst() }

            if tapTimes.count >= 2 {
                let intervals = zip(tapTimes, tapTimes.dropFirst()).map {
                    $1.timeIntervalSince($0)
                }
                let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
                engine.setBPM(60.0 / avgInterval)
            }
        } else {
            tapTimes = [now]
        }

        lastTapTime = now
    }
}

#Preview {
    TapTempoButton()
        .environment(MetronomeEngine())
}
