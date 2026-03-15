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
            Text("BPM")
                .font(.caption)
                .foregroundStyle(.secondary)
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
