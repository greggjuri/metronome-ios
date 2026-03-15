# 02-prp-bpm-input: Phase 2 BPM Input

**Created**: 2026-03-14
**Initial**: `INITs/02-init-bpm-input.md`
**Status**: Draft

---

## Overview

### Problem Statement

Phase 1 left the BPM hardcoded at 120 with no way to change it. Musicians need multiple BPM input methods: direct number entry, tap tempo, and quick +/- adjustments.

### Proposed Solution

Add three BPM input methods, all funnelling through the existing `MetronomeEngine.setBPM()`:

1. **Number Pad** — tap the BPM display to open a sheet with a digit pad for direct entry
2. **Tap Tempo** — dedicated button; averages intervals from last 4 taps
3. **+/- Buttons** — single tap for ±1, long press for continuous increment

Update `MetronomeEngine.setBPM()` to restart the audio engine when playing, so all BPM changes take effect immediately.

### Success Criteria

- [ ] Tapping BPM display opens number pad sheet
- [ ] Number pad entry updates BPM on confirm, dismisses on cancel
- [ ] Invalid / out-of-range input is silently clamped (no crash)
- [ ] Max 3 digits enforced on number pad
- [ ] - and + buttons change BPM by 1 per tap
- [ ] Long-pressing - or + accelerates change continuously
- [ ] Tap tempo sets BPM from 2+ taps (rolling 4-tap window)
- [ ] Tap sequence resets after 3 seconds of no taps
- [ ] All BPM changes take effect immediately while playing
- [ ] BPM display always shows current value as integer
- [ ] No force unwraps
- [ ] All new files under 150 lines

---

## Context

### Related Documentation

- `docs/PLANNING.md` — Phase 2 scope
- `docs/DECISIONS.md` — ADR-002 (AVAudioEngine for beats — Timer OK for UI), ADR-003 (@Observable), ADR-004 (separate engines)
- `docs/TESTING.md` — Device testing checklist

### Dependencies

- **Required**: Phase 1 complete (MetronomeEngine, AudioEngine, basic UI) — done
- **Optional**: None

### Files to Modify/Create

```
Metronome/Metronome/Views/BPMPad.swift              # NEW: number pad sheet
Metronome/Metronome/Views/TapTempoButton.swift       # NEW: tap tempo button + logic
Metronome/Metronome/Views/BPMControls.swift          # NEW: +/- buttons with long-press
Metronome/Metronome/Views/BPMDisplay.swift           # MODIFY: tappable, opens BPMPad sheet
Metronome/Metronome/ContentView.swift                # MODIFY: add new controls to layout
Metronome/Metronome/Models/MetronomeEngine.swift     # MODIFY: setBPM restarts audio if playing
```

---

## Technical Specification

### MetronomeEngine — `setBPM` update

```swift
func setBPM(_ newBPM: Double) {
    bpm = min(240, max(30, newBPM))
    if isPlaying {
        audioEngine.stop()
        audioEngine.start(bpm: bpm, beatsPerBar: beatsPerBar) { [weak self] beat in
            self?.beatFired(beat: beat)
        }
    }
}
```

Beat counter resets to 0 on restart — acceptable for Phase 2.

### BPMPad (new)

Sheet presented from BPMDisplay. Self-contained digit entry:

- `@State private var inputString: String` — initialised to current BPM as string
- `@Environment(MetronomeEngine.self) private var engine`
- `@Environment(\.dismiss) private var dismiss`
- Grid of digit buttons (0-9), backspace (⌫), cancel (✕), confirm (✓)
- Max 3 digits — reject 4th keypress
- Confirm: parse to Double, call `engine.setBPM()`, dismiss
- Cancel: dismiss without change

### TapTempoButton (new)

Self-contained view with own tap state:

- `@Environment(MetronomeEngine.self) private var engine`
- `@State private var tapTimes: [Date] = []`
- `@State private var lastTapTime: Date? = nil`
- On tap: if last tap < 3s ago, append time to rolling window (max 4), average intervals, call `setBPM(60.0 / avgInterval)`
- If > 3s since last tap, reset sequence
- Button label: "Tap" with min 60×60pt tap target

### BPMControls (new)

HStack with - and + buttons:

- Single tap: `engine.setBPM(engine.bpm ± 1)`
- Long press via `Timer` (this is UI interaction timing, not beat scheduling — ADR-002 compliant):
  - After 500ms hold, fire every 100ms
  - `@State private var holdTimer: Timer?`
- Use gesture combination: `LongPressGesture` + `DragGesture(minimumDistance: 0)` for press/release detection

### BPMDisplay update

Add `onTapGesture` and `@State private var showingPad = false`:

```swift
VStack(spacing: 4) { ... }
    .onTapGesture { showingPad = true }
    .sheet(isPresented: $showingPad) {
        BPMPad()
    }
```

Needs `@Environment(MetronomeEngine.self)` to pass BPM context.

### ContentView layout update

```
VStack(spacing: 40) {
    BeatIndicator(...)
    BPMDisplay(...)              ← tappable → sheet(BPMPad)
    BPMControls(...)             ← − | + with long press
    TapTempoButton(...)
    ControlButton(...)
}
```

### View Hierarchy

```
ContentView                        # @Environment(MetronomeEngine.self)
└── VStack(spacing: 40)
    ├── BeatIndicator              # currentBeat, isPlaying
    ├── BPMDisplay                 # bpm, tappable → sheet(BPMPad)
    │   └── BPMPad (sheet)         # digit entry, confirm/cancel
    ├── BPMControls                # −/+ buttons
    ├── TapTempoButton             # tap tempo
    └── ControlButton              # start/stop
```

---

## Implementation Steps

### Step 1: Update MetronomeEngine.setBPM()

**Files**: `Metronome/Metronome/Models/MetronomeEngine.swift` (modify)

Update `setBPM()` to restart audio engine when playing. This ensures all BPM input methods take immediate effect.

**Validation**:
- [ ] Builds without errors
- [ ] Existing start/stop still works

---

### Step 2: Create BPMPad

**Files**: `Metronome/Metronome/Views/BPMPad.swift` (new)

Implement the number pad sheet:
- 4×3 grid of digit buttons + bottom row (✕, 0, ⌫) + confirm button (✓)
- Live preview of typed number at top
- `inputString` initialised to current BPM
- Max 3 digits
- Confirm parses and calls `engine.setBPM()`

**Validation**:
- [ ] Builds without errors
- [ ] No force unwraps

---

### Step 3: Update BPMDisplay to be tappable

**Files**: `Metronome/Metronome/Views/BPMDisplay.swift` (modify)

- Change from `let bpm: Double` to reading from `@Environment(MetronomeEngine.self)`
- Add `@State private var showingPad = false`
- Add `.onTapGesture` and `.sheet(isPresented:)` presenting `BPMPad`

**Validation**:
- [ ] Builds without errors
- [ ] BPM still displays correctly

---

### Step 4: Create TapTempoButton

**Files**: `Metronome/Metronome/Views/TapTempoButton.swift` (new)

Implement tap tempo with rolling 4-tap window:
- Track tap times in `@State` array
- Calculate average interval from consecutive taps
- Reset if > 3 seconds since last tap
- Call `engine.setBPM(60.0 / avgInterval)` after each qualifying tap

**Validation**:
- [ ] Builds without errors
- [ ] No force unwraps

---

### Step 5: Create BPMControls

**Files**: `Metronome/Metronome/Views/BPMControls.swift` (new)

Implement +/- increment buttons:
- Single tap: ±1 BPM
- Long press: continuous increment via `Timer` (every 100ms after 500ms hold)
- Stop timer on release
- Buttons show "-" and "+" labels

**Validation**:
- [ ] Builds without errors
- [ ] No force unwraps

---

### Step 6: Update ContentView layout

**Files**: `Metronome/Metronome/ContentView.swift` (modify)

Add `BPMControls` and `TapTempoButton` to the VStack. Update `BPMDisplay` call (no longer passing `bpm:` since it reads from environment).

**Validation**:
- [ ] Builds without errors
- [ ] App launches on simulator
- [ ] All controls visible in layout
- [ ] BPM display shows value
- [ ] Number pad opens on tap

---

### Step 7: Simulator smoke test

```bash
xcodebuild -project Metronome/Metronome.xcodeproj -scheme Metronome \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Verify:
- [ ] Clean build
- [ ] App launches
- [ ] Tap BPM → pad opens, entry works, confirm/cancel work
- [ ] +/- buttons change BPM
- [ ] Tap tempo button present
- [ ] Start/stop still works

---

### Step 8: Commit and push

```bash
git add .
git commit -m "feat: Phase 2 BPM input — number pad, tap tempo, increment buttons"
git push
```

Update `docs/TASK.md`:
- Move Phase 2 to "Recently Completed"

**Validation**:
- [ ] Commit pushed to GitHub
- [ ] `docs/TASK.md` updated

---

## Testing Requirements

### Simulator Tests

- [ ] App launches without crash
- [ ] Tap BPM display → pad sheet appears
- [ ] Pad: type digits, see live preview
- [ ] Pad: confirm sets BPM, sheet dismisses
- [ ] Pad: cancel dismisses without change
- [ ] Pad: max 3 digits enforced
- [ ] Pad: backspace removes last digit
- [ ] +/- buttons change displayed BPM
- [ ] Tap tempo button is present and tappable
- [ ] Start/stop still works

### Device Tests

| # | Action | Expected Result | Pass? |
|---|--------|-----------------|-------|
| 1 | Set BPM to 60 via pad | Clicks at 1/second | ☐ |
| 2 | Set BPM to 240 via pad | Fast clicks, evenly spaced | ☐ |
| 3 | Enter 999 in pad, confirm | BPM clamped to 240 | ☐ |
| 4 | Enter 10 in pad, confirm | BPM clamped to 30 | ☐ |
| 5 | Change BPM while playing via pad | Audio restarts at new tempo immediately | ☐ |
| 6 | Change BPM while playing via +/- | Audio restarts at new tempo immediately | ☐ |
| 7 | Tap tempo 4 times at ~120 BPM | BPM reads ~120 | ☐ |
| 8 | Tap tempo, wait 4 seconds, tap again | Sequence resets (no wild BPM) | ☐ |
| 9 | Long press + button for 2 seconds | BPM increases continuously | ☐ |
| 10 | Long press - at BPM 30 | BPM stays at 30, no crash | ☐ |

---

## Error Handling

| Error | Cause | Handling |
|-------|-------|----------|
| Empty pad input confirmed | User taps ✓ with no digits | Guard: if inputString is empty, dismiss without change |
| Non-numeric pad input | Should be impossible (only digit buttons) | Parse with `Double()`, guard nil |
| BPM out of range | User enters 999 or 5 | `setBPM()` clamps to 30–240 |
| Audio restart fails | Engine error on setBPM while playing | Existing error handling in AudioEngine.start() logs and stays stopped |
| Rapid +/- at limits | Holding + at 240 or - at 30 | `setBPM()` clamp prevents out-of-range |

---

## Open Questions

- None — the init spec is comprehensive with code examples for all three input methods.

---

## Rollback Plan

If issues are discovered:
1. `git revert <commit-hash>` to undo the Phase 2 commit
2. `git push` to update remote
3. Verify: Phase 1 functionality intact — start/stop works at 120 BPM

---

## Confidence Scores

| Dimension | Score (1-10) | Notes |
|-----------|--------------|-------|
| Clarity | 9 | Init spec includes layout, algorithm, and code examples |
| Feasibility | 9 | Standard SwiftUI patterns — sheets, gestures, Timer for UI |
| Completeness | 9 | All three input methods fully specified |
| Alignment | 10 | Timer used only for UI long-press, not beat timing (ADR-002 compliant) |
| **Average** | **9.25** | Ready for execution |

---

## Notes

- `Timer` is used in BPMControls for long-press acceleration — this is for UI interaction (button repeat), NOT for beat scheduling. ADR-002 prohibits Timer for beat timing only.
- `setBPM()` restart approach (stop + start) causes a brief beat reset. This is acceptable for Phase 2 — smooth BPM transitions could be a Phase 4 enhancement.
- BPMDisplay changes from taking `let bpm: Double` to reading from `@Environment` — this is a minor API change that simplifies data flow.
- The tap tempo algorithm uses `Date()` for interval measurement — this is fine for human-speed tap detection (not audio-critical timing).
