# init-core-metronome

## Goal

Scaffold the full Phase 1 metronome: hardware-accurate click audio, BPM state,
play/stop control, and a 4-beat visual indicator. At the end of this PRP,
tapping Start produces accurate clicks and the beat indicator lights up in time.

---

## Xcode Project Setup

- App name: `Metronome`
- Bundle ID: `com.greggjuri.metronome`
- Language: Swift
- Interface: SwiftUI
- Minimum deployment: iOS 17 (targeting iOS 26)
- Uncheck: Core Data, Tests (add later if needed)

Create the folder structure manually after scaffolding:

```
Metronome/
├── MetronomeApp.swift
├── ContentView.swift
├── Models/
│   └── MetronomeEngine.swift
├── Audio/
│   └── AudioEngine.swift
├── Views/
│   ├── BPMDisplay.swift
│   ├── BeatIndicator.swift
│   └── ControlButton.swift
└── Assets.xcassets/
```

---

## Files to Create

### `Models/MetronomeEngine.swift`

`@Observable` class. Single source of truth.

**Properties:**
- `var bpm: Double = 120`  (clamped 30–240)
- `var isPlaying: Bool = false`
- `var currentBeat: Int = 0`  (0-indexed, 0–3 for 4/4)
- `var beatsPerBar: Int = 4`

**Methods:**
- `func start()` — validates BPM, calls `audioEngine.start(bpm:onBeat:)`, sets `isPlaying = true`
- `func stop()` — calls `audioEngine.stop()`, resets `isPlaying = false`, `currentBeat = 0`
- `func setBPM(_ newBPM: Double)` — clamps to 30–240, updates `bpm`
- `private func beatFired(beat: Int)` — callback from AudioEngine; updates `currentBeat` on main thread

**Owns** an `AudioEngine` instance (private).

---

### `Audio/AudioEngine.swift`

Non-`@Observable` class. Pure audio hardware concern.

**Properties:**
- `private var engine: AVAudioEngine`
- `private var playerNode: AVAudioPlayerNode`
- `private var clickBuffer: AVAudioPCMBuffer?`  — loaded once from asset
- `private var nextBeatTime: AVAudioTime?`
- `private var beatIndex: Int = 0`
- `private var isRunning: Bool = false`

**Methods:**
- `func start(bpm: Double, beatsPerBar: Int, onBeat: @escaping (Int) -> Void)` — configures session, starts engine, schedules first beat
- `func stop()` — stops scheduling, stops engine
- `private func scheduleNextBeat()` — schedules a buffer at `nextBeatTime`, advances `nextBeatTime` by one beat interval, recurses via completion handler
- `private func loadClickBuffer() -> AVAudioPCMBuffer?` — synthesises a short sine-wave click (440 Hz, 20ms) programmatically — no asset file needed for Phase 1

**AVAudioSession config** (call in `start()`):
```swift
let session = AVAudioSession.sharedInstance()
try session.setCategory(.playback, mode: .default)
try session.setActive(true)
```

**Scheduling pattern** (key detail):
```swift
// On each beat completion handler:
playerNode.scheduleBuffer(clickBuffer, at: nextBeatTime, completionCallbackType: .dataRendered) { _ in
    self.onBeat?(self.beatIndex)
    self.beatIndex = (self.beatIndex + 1) % self.beatsPerBar
    self.scheduleNextBeat()
}
```

Use `AVAudioTime(hostTime:)` for `nextBeatTime`. Derive beat interval:
```swift
let secondsPerBeat = 60.0 / bpm
let hostTicksPerBeat = secondsPerBeat * hostTicksPerSecond()
```

Helper:
```swift
private func hostTicksPerSecond() -> Double {
    var info = mach_timebase_info_data_t()
    mach_timebase_info(&info)
    return 1_000_000_000.0 * Double(info.denom) / Double(info.numer)
}
```

---

### `Views/BPMDisplay.swift`

Simple view. Displays `engine.bpm` as a large integer.

```
┌──────────────┐
│     120      │  ← SF Pro, ~80pt, bold
│     BPM      │  ← caption, secondary color
└──────────────┘
```

No interaction in Phase 1 (tapping opens pad in Phase 2).

---

### `Views/BeatIndicator.swift`

Displays 4 circles in a row. Active beat is highlighted (accent color or white).
Beat 0 (downbeat) uses a slightly larger or differently colored circle.

```
○ ○ ○ ○   (stopped)
● ○ ○ ○   (beat 0 active)
○ ● ○ ○   (beat 1 active)
```

Takes `currentBeat: Int` and `isPlaying: Bool` as inputs.
Animate highlight with `.animation(.easeOut(duration: 0.05), value: currentBeat)`.

---

### `Views/ControlButton.swift`

Single large rounded button. Shows "Start" or "Stop" based on `isPlaying`.

- Use `.buttonStyle(.borderedProminent)` as placeholder (Phase 3 adds liquid glass)
- Min tap target: 60×60pt

---

### `ContentView.swift`

Vertical stack layout:

```swift
VStack(spacing: 40) {
    BeatIndicator(currentBeat: engine.currentBeat, isPlaying: engine.isPlaying)
    BPMDisplay(bpm: engine.bpm)
    ControlButton(isPlaying: engine.isPlaying) {
        engine.isPlaying ? engine.stop() : engine.start()
    }
}
```

Inject `MetronomeEngine` via `.environment` from `MetronomeApp.swift`.

---

### `MetronomeApp.swift`

```swift
@main
struct MetronomeApp: App {
    @State private var engine = MetronomeEngine()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(engine)
        }
    }
}
```

---

## Click Sound Generation

Synthesise programmatically in `AudioEngine` — no audio asset needed.

```swift
private func makeClickBuffer(engine: AVAudioEngine) -> AVAudioPCMBuffer? {
    let format = engine.outputNode.inputFormat(forBus: 0)
    let sampleRate = format.sampleRate
    let duration = 0.02  // 20ms
    let frameCount = AVAudioFrameCount(sampleRate * duration)

    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
    buffer.frameLength = frameCount

    let freq = 880.0  // Hz — bright click
    for i in 0..<Int(frameCount) {
        let t = Double(i) / sampleRate
        let envelope = max(0, 1.0 - t / duration)  // linear decay
        let sample = Float(sin(2 * .pi * freq * t) * envelope * 0.8)
        for ch in 0..<Int(format.channelCount) {
            buffer.floatChannelData?[ch][i] = sample
        }
    }
    return buffer
}
```

---

## Acceptance Criteria

- [ ] App launches without crash
- [ ] Tapping Start plays a click sound immediately
- [ ] Clicks continue at the correct interval for the set BPM
- [ ] Beat indicator cycles through 4 beats in sync with audio
- [ ] Tapping Stop halts audio and resets beat indicator
- [ ] No timing drift audible after 2 minutes of playback (test on device)
- [ ] No force unwraps (`!`) anywhere in new code
- [ ] All new files are under 150 lines

---

## Out of Scope (Phase 2+)

- BPM input (number pad, tap tempo, +/- buttons)
- Liquid glass styling
- Haptic feedback
- Background audio
- Time signatures
- Persistence

---

## Git

Commit message when done: `feat: Phase 1 core metronome — audio engine, beat state, basic UI`
Push immediately after.
