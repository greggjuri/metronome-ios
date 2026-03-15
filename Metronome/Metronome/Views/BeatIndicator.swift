//
//  BeatIndicator.swift
//  Metronome
//

import SwiftUI

struct BeatIndicator: View {
    let currentBeat: Int
    let isPlaying: Bool
    let beatsPerBar: Int = 4

    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<beatsPerBar, id: \.self) { beat in
                Circle()
                    .fill(fillColor(for: beat))
                    .frame(width: beat == 0 ? 20 : 16, height: beat == 0 ? 20 : 16)
            }
        }
        .animation(.easeOut(duration: 0.05), value: currentBeat)
    }

    private func fillColor(for beat: Int) -> Color {
        guard isPlaying, beat == currentBeat else {
            return .gray.opacity(0.3)
        }
        return beat == 0 ? .primary : .accentColor
    }
}

#Preview {
    VStack(spacing: 20) {
        BeatIndicator(currentBeat: 0, isPlaying: false)
        BeatIndicator(currentBeat: 0, isPlaying: true)
        BeatIndicator(currentBeat: 2, isPlaying: true)
    }
}
