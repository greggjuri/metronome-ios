//
//  BPMDisplay.swift
//  Metronome
//

import SwiftUI

struct BPMDisplay: View {
    let bpm: Double

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(bpm))")
                .font(.system(size: 80, weight: .thin, design: .rounded))
            Text("BPM")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    BPMDisplay(bpm: 120)
}
