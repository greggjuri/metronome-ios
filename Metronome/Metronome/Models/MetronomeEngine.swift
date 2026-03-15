//
//  MetronomeEngine.swift
//  Metronome
//

import Foundation
import Observation

@Observable
class MetronomeEngine {

    // MARK: - Properties

    var bpm: Double = 120
    var isPlaying: Bool = false
    var currentBeat: Int = 0
    var beatsPerBar: Int = 4

    private var audioEngine = AudioEngine()

    // MARK: - Public

    func start() {
        setBPM(bpm)
        audioEngine.start(bpm: bpm, beatsPerBar: beatsPerBar) { [weak self] beat in
            self?.beatFired(beat: beat)
        }
        isPlaying = true
    }

    func stop() {
        audioEngine.stop()
        isPlaying = false
        currentBeat = 0
    }

    func setBPM(_ newBPM: Double) {
        bpm = min(240, max(30, newBPM))
    }

    // MARK: - Private

    private func beatFired(beat: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.currentBeat = beat
        }
    }
}
