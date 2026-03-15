//
//  ControlButton.swift
//  Metronome
//

import SwiftUI

struct ControlButton: View {
    let isPlaying: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(isPlaying ? "Stop" : "Start")
                .font(.title2)
                .frame(minWidth: 60, minHeight: 60)
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    VStack(spacing: 20) {
        ControlButton(isPlaying: false) { }
        ControlButton(isPlaying: true) { }
    }
}
