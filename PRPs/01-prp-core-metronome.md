# 01-prp-core-metronome: Phase 1 Core Metronome

**Created**: 2026-03-14
**Initial**: `INITs/01-init-core-metronome.md`
**Status**: Draft

---

## Overview

### Problem Statement

The Metronome app currently has only the default Xcode scaffold — no audio, no state, no meaningful UI. We need the foundational metronome: hardware-accurate click audio via AVAudioEngine, BPM state management, play/stop control, and a 4-beat visual indicator that lights up in sync with the clicks.

### Proposed Solution

Build three layers:
1. **AudioEngine** — AVAudioEngine + AVAudioPlayerNode scheduling click buffers on the hardware clock (`AVAudioTime`), with a programmatically synthesised 880 Hz sine-wave click
2. **MetronomeEngine** — `@Observable` class owning BPM state, play/stop logic, and beat counter, delegating audio to AudioEngine
3. **SwiftUI Views** — BPMDisplay, BeatIndicator, ControlButton wired to MetronomeEngine via `.environment()`

### Success Criteria

- [ ] App launches without crash on simulator
- [ ] Tapping Start plays a click sound immediately
- [ ] Clicks continue at the correct interval for the set BPM (120 default)
- [ ] Beat indicator cycles through 4 beats in sync with audio
- [ ] Tapping Stop halts audio and resets beat indicator to beat 0
- [ ] No timing drift audible after 2 minutes of playback (device test)
- [ ] No force unwraps (`!`) anywhere in new code
- [ ] All new files are under 150 lines

---

## Context

### Related Documentation

- `docs/PLANNING.md` — Architecture overview, data flow diagram
- `docs/DECISIONS.md` — ADR-001 (SwiftUI), ADR-002 (AVAudioEngine), ADR-003 (@Observable), ADR-004 (separate engines)
- `docs/TESTING.md` — Device testing checklist, timing tuning log

### Dependencies

- **Required**: None — this is the first feature
- **Optional**: None

### Files to Modify/Create

```
Metronome/Metronome/Models/MetronomeEngine.swift   # NEW: @Observable state + play/stop logic
Metronome/Metronome/Audio/AudioEngine.swift         # NEW: AVAudioEngine scheduling
Metronome/Metronome/Views/BPMDisplay.swift          # NEW: Large BPM number display
Metronome/Metronome/Views/BeatIndicator.swift       # NEW: 4-beat visual indicator
Metronome/Metronome/Views/ControlButton.swift       # NEW: Start/Stop button
Metronome/Metronome/ContentView.swift               # MODIFY: Wire up views and engine
Metronome/Metronome/MetronomeApp.swift              # MODIFY: Create and inject MetronomeEngine
```

---

## Technical Specification

### New Swift Types

```swift
// Models/MetronomeEngine.swift
import Observation

@Observable
class MetronomeEngine {
    var bpm: Double = 120          // clamped 30–240
    var isPlaying: Bool = false
    var currentBeat: Int = 0       // 0-indexed, 0–3 for 4/4
    var beatsPerBar: Int = 4

    private var audioEngine = AudioEngine()

    func start()
    func stop()
    func setBPM(_ newBPM: Double)
    private func beatFired(beat: Int)  // callback from AudioEngine, dispatches to main
}
```

```swift
// Audio/AudioEngine.swift
import AVFoundation

class AudioEngine {
    private var engine: AVAudioEngine
    private var playerNode: AVAudioPlayerNode
    private var clickBuffer: AVAudioPCMBuffer?
    private var nextBeatTime: AVAudioTime?
    private var beatIndex: Int = 0
    private var beatsPerBar: Int = 4
    private var isRunning: Bool = false
    private var onBeat: ((Int) -> Void)?

    func start(bpm: Double, beatsPerBar: Int, onBeat: @escaping (Int) -> Void)
    func stop()
    private func scheduleNextBeat(bpm: Double)
    private func makeClickBuffer() -> AVAudioPCMBuffer?
    private func hostTicksPerSecond() -> Double
}
```

### View Hierarchy

```
MetronomeApp
└── ContentView                    # @Environment(MetronomeEngine.self)
    └── VStack(spacing: 40)
        ├── BeatIndicator          # currentBeat, isPlaying
        ├── BPMDisplay             # bpm
        └── ControlButton          # isPlaying, toggle action
```

### Audio Architecture

**AVAudioEngine graph:**
```
AVAudioPlayerNode → AVAudioEngine.mainMixerNode → AVAudioEngine.outputNode
```

**Scheduling pattern:**
1. On `start()`: configure AVAudioSession (.playback), start engine, start playerNode
2. Capture current hardware time via `playerNode.lastRenderTime` + `hostTime`
3. Schedule first click buffer at current time
4. In completion handler (`.dataRendered`): fire `onBeat` callback, advance `nextBeatTime` by one beat interval in host ticks, schedule next buffer
5. On `stop()`: set `isRunning = false`, stop playerNode, stop engine

**Beat interval calculation:**
```swift
let secondsPerBeat = 60.0 / bpm
let hostTicksPerBeat = secondsPerBeat * hostTicksPerSecond()
// nextBeatTime = AVAudioTime(hostTime: previousHostTime + UInt64(hostTicksPerBeat))
```

**Click synthesis:** 880 Hz sine wave, 20ms duration, linear amplitude decay envelope, 0.8 peak amplitude. Generated once in `makeClickBuffer()` using the engine's output format.

---

## Implementation Steps

### Step 1: Create folder structure

**Files**: `Metronome/Metronome/Models/`, `Metronome/Metronome/Audio/`, `Metronome/Metronome/Views/`

Create the three subdirectories within the Xcode project source folder.

**Validation**:
- [ ] Directories exist

---

### Step 2: AudioEngine

**Files**: `Metronome/Metronome/Audio/AudioEngine.swift` (new)

Implement the full `AudioEngine` class:

1. Properties: `engine`, `playerNode`, `clickBuffer`, `nextBeatTime`, `beatIndex`, `beatsPerBar`, `isRunning`, `onBeat` callback, `bpm`
2. `init()`: create `AVAudioEngine` and `AVAudioPlayerNode`, attach player to engine
3. `start(bpm:beatsPerBar:onBeat:)`:
   - Configure `AVAudioSession` with `.playback` category
   - Set `self.bpm`, `self.beatsPerBar`, `self.onBeat`
   - Generate click buffer via `makeClickBuffer()`
   - Connect playerNode to mainMixerNode using the output format
   - Start engine, start playerNode
   - Capture initial `nextBeatTime` from `playerNode.lastRenderTime`
   - Set `isRunning = true`, reset `beatIndex = 0`
   - Call `scheduleNextBeat()`
4. `stop()`:
   - Set `isRunning = false`
   - Stop playerNode, stop engine
5. `scheduleNextBeat()`:
   - Guard `isRunning` and `clickBuffer` exists
   - Schedule buffer at `nextBeatTime` with `.dataRendered` completion
   - In completion: call `onBeat?(beatIndex)`, increment beatIndex mod beatsPerBar, advance `nextBeatTime` by one beat in host ticks, recurse
6. `makeClickBuffer()`: 880 Hz sine, 20ms, linear decay, using engine output format
7. `hostTicksPerSecond()`: mach_timebase_info conversion

**Validation**:
- [ ] Builds without errors
- [ ] No force unwraps

---

### Step 3: MetronomeEngine

**Files**: `Metronome/Metronome/Models/MetronomeEngine.swift` (new)

Implement the `@Observable` class:

1. Properties: `bpm` (Double, default 120), `isPlaying` (Bool), `currentBeat` (Int), `beatsPerBar` (Int, 4)
2. Private `audioEngine = AudioEngine()`
3. `start()`: validate BPM is in range, call `audioEngine.start(bpm:beatsPerBar:onBeat:)` with `beatFired` as callback, set `isPlaying = true`
4. `stop()`: call `audioEngine.stop()`, set `isPlaying = false`, reset `currentBeat = 0`
5. `setBPM(_ newBPM: Double)`: clamp to 30–240, assign to `bpm`
6. `beatFired(beat:)`: dispatch to `DispatchQueue.main.async` to update `currentBeat`

**Validation**:
- [ ] Builds without errors
- [ ] No force unwraps

---

### Step 4: BPMDisplay view

**Files**: `Metronome/Metronome/Views/BPMDisplay.swift` (new)

Simple view displaying `bpm` as a large integer:
- `let bpm: Double`
- Large number: `.font(.system(size: 80, weight: .thin, design: .rounded))`
- "BPM" caption below in `.secondary` color

**Validation**:
- [ ] Builds without errors
- [ ] Preview renders

---

### Step 5: BeatIndicator view

**Files**: `Metronome/Metronome/Views/BeatIndicator.swift` (new)

Displays 4 circles in a row:
- `let currentBeat: Int`
- `let isPlaying: Bool`
- Active beat: filled circle (accent color), inactive: outline
- Beat 0 (downbeat): slightly larger circle or different color to distinguish
- Animate with `.animation(.easeOut(duration: 0.05), value: currentBeat)`

**Validation**:
- [ ] Builds without errors
- [ ] Preview renders with different beat states

---

### Step 6: ControlButton view

**Files**: `Metronome/Metronome/Views/ControlButton.swift` (new)

Single large button:
- `let isPlaying: Bool`
- `let action: () -> Void`
- Label: "Start" / "Stop" based on `isPlaying`
- Style: `.buttonStyle(.borderedProminent)` (Phase 3 will add liquid glass)
- Minimum tap target: 60×60pt via `.frame(minWidth: 60, minHeight: 60)`

**Validation**:
- [ ] Builds without errors
- [ ] Preview renders in both states

---

### Step 7: Wire up ContentView

**Files**: `Metronome/Metronome/ContentView.swift` (modify)

Replace default scaffold with:
```swift
@Environment(MetronomeEngine.self) private var engine

var body: some View {
    VStack(spacing: 40) {
        BeatIndicator(currentBeat: engine.currentBeat, isPlaying: engine.isPlaying)
        BPMDisplay(bpm: engine.bpm)
        ControlButton(isPlaying: engine.isPlaying) {
            engine.isPlaying ? engine.stop() : engine.start()
        }
    }
}
```

**Validation**:
- [ ] Builds without errors

---

### Step 8: Wire up MetronomeApp

**Files**: `Metronome/Metronome/MetronomeApp.swift` (modify)

Add engine state and inject via environment:
```swift
@State private var engine = MetronomeEngine()

var body: some Scene {
    WindowGroup {
        ContentView()
            .environment(engine)
    }
}
```

**Validation**:
- [ ] Builds without errors
- [ ] App launches on simulator without crash
- [ ] Tapping Start produces audio
- [ ] Beat indicator animates
- [ ] Tapping Stop halts audio and resets indicator

---

### Step 9: Simulator smoke test

Run a full build and launch in simulator:
```bash
xcodebuild -scheme Metronome -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Verify:
- [ ] Clean build, no warnings
- [ ] App launches
- [ ] Start/stop toggles
- [ ] BPM displays 120
- [ ] Beat dots visible and animating

---

### Step 10: Commit and push

```bash
git add .
git commit -m "feat: Phase 1 core metronome — audio engine, beat state, basic UI"
git push
```

Update `docs/TASK.md`:
- Move `01-init-core-metronome` from "Up Next" to "Recently Completed"
- Add date

**Validation**:
- [ ] Commit pushed to GitHub
- [ ] `docs/TASK.md` updated

---

## Testing Requirements

### Unit Tests (deferred)

Unit tests are not part of this PRP per the init spec ("Uncheck: Tests — add later if needed"). The following tests should be added in a future PRP:
- `testBPMClampedToMinimum`: setBPM(10) → bpm == 30
- `testBPMClampedToMaximum`: setBPM(999) → bpm == 240
- `testBeatInterval`: 60.0 / 120.0 == 0.5

### Simulator Tests

- [ ] App launches without crash
- [ ] BPM display shows "120"
- [ ] Start/stop button state toggles correctly
- [ ] Beat indicator renders 4 circles
- [ ] No console errors on launch

### Device Tests

| # | Action | Expected Result | Pass? |
|---|--------|-----------------|-------|
| 1 | Launch app | UI renders, ready to play | ☐ |
| 2 | Tap Start at 120 BPM | Clicks at 2 per second (0.5s interval) | ☐ |
| 3 | Listen for 2 minutes | No audible drift | ☐ |
| 4 | Tap Stop | Clicks stop cleanly, beat indicator resets | ☐ |
| 5 | Rapid Start/Stop toggling | No crash, no hanging audio | ☐ |
| 6 | Silent mode switch ON | Audio still plays (.playback category) | ☐ |

---

## Error Handling

| Error | Cause | Handling |
|-------|-------|----------|
| AVAudioSession activation failure | Audio hardware busy / permissions | Log error via `print()`, don't crash |
| AVAudioEngine start failure | System audio error | Catch in do/try, log, remain in stopped state |
| Interruption (phone call) | Incoming call | Not handled in Phase 1 — audio will stop naturally; proper handling in Phase 4 |
| Buffer creation returns nil | Format mismatch | Guard with early return, engine stays stopped |

---

## Open Questions

- None — the init spec is comprehensive and all requirements are clear.

---

## Rollback Plan

If issues are discovered:
1. `git revert <commit-hash>` to undo the Phase 1 commit
2. `git push` to update remote
3. Verify: build succeeds with just the default scaffold, app launches

---

## Confidence Scores

| Dimension | Score (1-10) | Notes |
|-----------|--------------|-------|
| Clarity | 9 | Init spec is detailed with code examples for every component |
| Feasibility | 9 | Standard AVAudioEngine pattern, well-documented Apple APIs |
| Completeness | 9 | All files, types, methods, and wiring specified |
| Alignment | 10 | Follows all 4 ADRs, no contradictions |
| **Average** | **9.25** | Ready for execution |

---

## Notes

- The click is synthesised programmatically (880 Hz sine, 20ms) — no audio asset file needed
- `AVAudioTime(hostTime:)` uses Mach absolute time, which is monotonic and independent of wall clock — this is what ensures drift-free scheduling
- The completion handler callback (`.dataRendered`) fires when the audio data has been consumed by the hardware, making it the right place to schedule the next beat
- BPM is stored as `Double` (not `Int`) to support future precision, but displayed as an integer in Phase 1
- Phase 1 uses `.borderedProminent` button style — liquid glass styling comes in Phase 3
