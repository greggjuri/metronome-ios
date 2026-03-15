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
        HStack(spacing: 20) {
            ForEach(0..<beatsPerBar, id: \.self) { beat in
                let active = isPlaying && beat == currentBeat
                let isDownbeat = beat == 0

                Circle()
                    .fill(fillColor(for: beat))
                    .frame(width: isDownbeat ? 20 : 16, height: isDownbeat ? 20 : 16)
                    .scaleEffect(active ? 1.3 : 1.0)
                    .shadow(
                        color: active ? .accentColor.opacity(0.8) : .clear,
                        radius: active ? 8 : 0
                    )
            }
        }
        .animation(.spring(response: 0.15, dampingFraction: 0.5), value: currentBeat)
        .animation(.easeOut(duration: 0.3), value: isPlaying)
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
