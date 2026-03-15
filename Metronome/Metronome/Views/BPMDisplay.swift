//
//  BPMDisplay.swift
//  Metronome
//

import SwiftUI

struct BPMDisplay: View {
    @Environment(MetronomeEngine.self) private var engine
    @State private var showingPad = false

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(engine.bpm))")
                .font(.system(size: 80, weight: .thin, design: .rounded))
                .contentTransition(.numericText())
                .animation(.default, value: engine.bpm)

            Text("BPM")
                .font(.caption)
                .foregroundStyle(.secondary)

            if !engine.isPlaying {
                Text("tap to edit")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .onTapGesture { showingPad = true }
        .sheet(isPresented: $showingPad) {
            BPMPad()
        }
    }
}

#Preview {
    BPMDisplay()
        .environment(MetronomeEngine())
}
