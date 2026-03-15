//
//  MetronomeEngine.swift
//  Metronome
//

import Foundation
import Observation
import UIKit

@Observable
class MetronomeEngine {

    // MARK: - Properties

    var bpm: Double = 120
    var isPlaying: Bool = false
    var currentBeat: Int = 0
    var beatsPerBar: Int = 4

    private var audioEngine = AudioEngine()
    private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)

    // MARK: - Public

    func start() {
        setBPM(bpm)
        heavyHaptic.prepare()
        lightHaptic.prepare()
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
        if isPlaying {
            audioEngine.stop()
            audioEngine.start(bpm: bpm, beatsPerBar: beatsPerBar) { [weak self] beat in
                self?.beatFired(beat: beat)
            }
        }
    }

    // MARK: - Private

    private func beatFired(beat: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.currentBeat = beat
            if beat == 0 { self.heavyHaptic.impactOccurred() }
            else         { self.lightHaptic.impactOccurred() }
        }
    }
}
