//
//  AudioEngine.swift
//  Metronome
//

import AVFoundation

class AudioEngine {

    // MARK: - Properties

    private var engine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var clickBuffer: AVAudioPCMBuffer?
    private var nextBeatTime: AVAudioTime?
    private var beatIndex: Int = 0
    private var beatsPerBar: Int = 4
    private var isRunning: Bool = false
    private var bpm: Double = 120
    private var onBeat: ((Int) -> Void)?

    // MARK: - Init

    init() {
        engine.attach(playerNode)
    }

    // MARK: - Public

    func start(bpm: Double, beatsPerBar: Int, onBeat: @escaping (Int) -> Void) {
        self.bpm = bpm
        self.beatsPerBar = beatsPerBar
        self.onBeat = onBeat
        self.beatIndex = 0

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
            return
        }

        let format = engine.outputNode.inputFormat(forBus: 0)
        clickBuffer = makeClickBuffer(format: format)

        guard clickBuffer != nil else {
            print("Failed to create click buffer")
            return
        }

        engine.connect(playerNode, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
        } catch {
            print("Audio engine start error: \(error.localizedDescription)")
            return
        }

        playerNode.play()
        isRunning = true

        guard let lastRenderTime = playerNode.lastRenderTime,
              lastRenderTime.isHostTimeValid else {
            print("No valid render time available")
            stop()
            return
        }

        nextBeatTime = AVAudioTime(hostTime: lastRenderTime.hostTime)
        scheduleNextBeat()
    }

    func stop() {
        isRunning = false
        playerNode.stop()
        engine.stop()
    }

    // MARK: - Private

    private func scheduleNextBeat() {
        guard isRunning,
              let buffer = clickBuffer,
              let beatTime = nextBeatTime else { return }

        playerNode.scheduleBuffer(buffer, at: beatTime, completionCallbackType: .dataRendered) { [weak self] _ in
            guard let self, self.isRunning else { return }

            self.onBeat?(self.beatIndex)
            self.beatIndex = (self.beatIndex + 1) % self.beatsPerBar

            let secondsPerBeat = 60.0 / self.bpm
            let hostTicksPerBeat = UInt64(secondsPerBeat * self.hostTicksPerSecond())
            self.nextBeatTime = AVAudioTime(hostTime: beatTime.hostTime + hostTicksPerBeat)
            self.scheduleNextBeat()
        }
    }

    private func makeClickBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        let duration = 0.02 // 20ms
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        buffer.frameLength = frameCount

        let freq = 880.0
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let envelope = max(0, 1.0 - t / duration)
            let sample = Float(sin(2.0 * .pi * freq * t) * envelope * 0.8)
            for ch in 0..<Int(format.channelCount) {
                buffer.floatChannelData?[ch][i] = sample
            }
        }
        return buffer
    }

    private func hostTicksPerSecond() -> Double {
        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        return 1_000_000_000.0 * Double(info.denom) / Double(info.numer)
    }
}
