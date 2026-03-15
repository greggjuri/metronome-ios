//
//  ContentView.swift
//  Metronome
//
//  Created by Juri Gregg on 3/14/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(MetronomeEngine.self) private var engine

    var body: some View {
        VStack(spacing: 40) {
            BeatIndicator(currentBeat: engine.currentBeat, isPlaying: engine.isPlaying)
            BPMDisplay()
            BPMControls()
            TapTempoButton()
            ControlButton(isPlaying: engine.isPlaying) {
                engine.isPlaying ? engine.stop() : engine.start()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(MetronomeEngine())
}
