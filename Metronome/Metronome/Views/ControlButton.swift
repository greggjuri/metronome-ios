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
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
        }
        .tint(isPlaying ? .red : .accentColor)
        .glassEffect(.regular.interactive())
        .animation(.easeInOut(duration: 0.2), value: isPlaying)
    }
}

#Preview {
    VStack(spacing: 20) {
        ControlButton(isPlaying: false) { }
        ControlButton(isPlaying: true) { }
    }
}
