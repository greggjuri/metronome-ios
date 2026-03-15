# init-bpm-input

## Goal

Add all BPM input methods: a number pad for direct entry, tap tempo, and +/− increment
buttons. After this PRP, every practical way a musician sets BPM is covered.

---

## Context

Phase 1 left `BPMDisplay` non-interactive — tapping it does nothing. Phase 2 wires it up.
`MetronomeEngine.setBPM()` already exists and clamps to 30–240. All input methods funnel
through it.

---

## Features

### 1. Number Pad

Tapping the BPM display opens a number pad overlay. Musician types a number, confirms,
display updates. Same UX as the web version.

**Behaviour:**
- Tap BPMDisplay → pad appears (sheet or overlay)
- Digits build a string: "1" → "12" → "120"
- Confirm (✓) button: parse, clamp 30–240, call `engine.setBPM()`, dismiss
- Clear (⌫) button: delete last digit
- Cancel (✕): dismiss without change
- If metronome is playing, BPM change takes effect immediately (AudioEngine restart)
- Max 3 digits — reject a 4th keypress

**Layout:**
```
┌─────────────────────────┐
│          120            │  ← live preview of typed number
├─────┬─────┬─────────────┤
│  7  │  8  │  9          │
├─────┼─────┼─────────────┤
│  4  │  5  │  6          │
├─────┼─────┼─────────────┤
│  1  │  2  │  3          │
├─────┼─────┼─────────────┤
│  ✕  │  0  │  ⌫          │
├─────┴─────┴─────────────┤
│          ✓              │
└─────────────────────────┘
```

---

### 2. Tap Tempo

A dedicated "Tap" button. Musician taps it in time; BPM is calculated from the interval
between taps.

**Behaviour:**
- Minimum 2 taps to produce a BPM reading
- Use last 4 taps (rolling window) for averaging — reduces jitter
- Taps older than 3 seconds reset the sequence (new phrase)
- Result clamped to 30–240 via `setBPM()`
- Live update: BPM display updates after each tap (from tap 2 onwards)
- If playing, audio tempo updates immediately

**Algorithm:**
```swift
// On each tap:
let now = Date()
if let last = lastTapTime, now.timeIntervalSince(last) < 3.0 {
    tapTimes.append(now)
    if tapTimes.count > 4 { tapTimes.removeFirst() }
    if tapTimes.count >= 2 {
        let intervals = zip(tapTimes, tapTimes.dropFirst()).map { $1.timeIntervalSince($0) }
        let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
        engine.setBPM(60.0 / avgInterval)
    }
} else {
    tapTimes = [now]  // reset
}
lastTapTime = now
```

---

### 3. +/− Increment Buttons

Two buttons flanking the BPM display. Each tap adjusts BPM by ±1.
Long press accelerates: after 500ms hold, increment every 100ms.

**Behaviour:**
- Single tap: ±1 BPM
- Long press: ±1 BPM on first fire, then continuous at 10 BPM/sec after 500ms
- Clamped at 30 and 240 (buttons do nothing at limits)
- If playing, audio tempo updates immediately

---

## Files to Create/Modify

```
Metronome/Metronome/Views/BPMPad.swift          # NEW: number pad overlay
Metronome/Metronome/Views/TapTempoButton.swift  # NEW: tap tempo button + logic
Metronome/Metronome/Views/BPMDisplay.swift      # MODIFY: tappable, opens BPMPad
Metronome/Metronome/Views/BPMControls.swift     # NEW: +/− buttons with long-press
Metronome/Metronome/ContentView.swift           # MODIFY: add TapTempo + BPMControls
Metronome/Metronome/Models/MetronomeEngine.swift # MODIFY: setBPM triggers audio restart if playing
```

---

## Technical Specification

### `Views/BPMPad.swift`

`@Binding var bpm: Double` + `@Binding var isPresented: Bool` (or use dismiss env).

State:
- `@State private var inputString: String = ""`  — initialised to `"\(Int(bpm))"`

Presented as `.sheet` from `BPMDisplay`.

Confirm action:
```swift
if let value = Double(inputString) {
    engine.setBPM(value)  // clamp handled inside setBPM
}
dismiss()
```

Digit buttons: append to `inputString` if `inputString.count < 3`.
Backspace: `inputString.removeLast()` (guard not empty).

---

### `Views/TapTempoButton.swift`

Self-contained view managing its own tap state.
Takes `engine: MetronomeEngine` from environment.

Properties:
- `@State private var tapTimes: [Date] = []`
- `@State private var lastTapTime: Date? = nil`

Button label: "Tap" — large enough tap target (min 60×60pt).

---

### `Views/BPMControls.swift`

HStack with − button, spacer, + button.
Long-press handled via a `Timer` stored in `@State`:

```swift
@State private var holdTimer: Timer? = nil

func startHold(delta: Double) {
    holdTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
        engine.setBPM(engine.bpm + delta)
    }
}

func stopHold() {
    holdTimer?.invalidate()
    holdTimer = nil
}
```

Use `.simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded { _ in startHold(...) })`
combined with a `DragGesture(minimumDistance: 0).onEnded { _ in stopHold() }` to detect release.

---

### `MetronomeEngine` — `setBPM` update

If `isPlaying == true` when `setBPM` is called, restart the audio engine at the new BPM:

```swift
func setBPM(_ newBPM: Double) {
    bpm = min(240, max(30, newBPM))
    if isPlaying {
        audioEngine.stop()
        audioEngine.start(bpm: bpm, beatsPerBar: beatsPerBar, onBeat: beatFired)
    }
}
```

Beat counter resets to 0 on restart — acceptable for Phase 2.

---

### `ContentView` layout update

```
VStack(spacing: 40) {
    BeatIndicator(...)
    BPMDisplay(...)          ← tappable → sheet(BPMPad)
    BPMControls(...)         ← − | + with long press
    TapTempoButton(...)
    ControlButton(...)
}
```

---

## Acceptance Criteria

- [ ] Tapping BPM display opens number pad
- [ ] Number pad entry updates BPM on confirm, dismisses on cancel
- [ ] Invalid / out-of-range input is silently clamped (no crash, no alert)
- [ ] − and + buttons change BPM by 1 per tap
- [ ] Long-pressing − or + accelerates change continuously
- [ ] Tap tempo sets BPM from 2+ taps
- [ ] Tap sequence resets after 3 seconds of no taps
- [ ] All BPM changes take effect immediately while playing (no restart required from user)
- [ ] BPM display always shows current value (integer)
- [ ] No force unwraps
- [ ] All new files under 150 lines

---

## Out of Scope (Phase 3+)

- Liquid glass styling on the pad or buttons
- Haptic feedback on taps/beats
- Saving last-used BPM (UserDefaults — Phase 4)
- Swipe gesture on BPM display to nudge value

---

## Git

Commit message when done: `feat: Phase 2 BPM input — number pad, tap tempo, increment buttons`
Push immediately after.
