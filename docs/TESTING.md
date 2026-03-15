# Metronome iOS - Testing Standards

## Testing Reality for a Metronome App

UI and logic are simulator-testable. Audio timing accuracy requires a physical device
and a human ear (or a reference metronome to compare against).

```
        /\
       /  \     Device testing (primary — timing accuracy, audio feel)
      /----\
     /      \   Simulator (layout, UI, state, no-crash check)
    /--------\
   /          \ XCTest unit tests (BPM calculations, range validation)
  --------------
```

## Test Types

| Test Type | When | How |
|-----------|------|-----|
| XCTest unit | BPM math, range clamping, beat sequencing logic | `xcodebuild test` |
| Simulator | Launch, UI layout, state changes, no-crash | Xcode Simulator |
| Device | Timing accuracy, audio quality, drift over time | Physical iPhone |

## Running Tests

```bash
# Run unit tests (simulator)
xcodebuild test \
  -scheme Metronome \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Build for device
xcodebuild \
  -scheme Metronome \
  -destination 'platform=iOS,name=My iPhone' \
  build
```

## Before Every Commit

- [ ] Project builds without errors
- [ ] No Swift warnings treated as errors
- [ ] If unit tests exist: all pass
- [ ] Commit message is conventional format

## Device Testing Checklist

Run after every audio/timing feature on physical iPhone:

### Timing Accuracy
- [ ] Clicks sound evenly spaced at 60 BPM (1 per second)
- [ ] Clicks sound evenly spaced at 120 BPM
- [ ] Clicks sound evenly spaced at 240 BPM (fast — should feel mechanical, not rushed)
- [ ] No audible drift after 2 minutes continuous playback
- [ ] No drift when screen is locked and app continues playing (Phase 4)

### BPM Input
- [ ] Number pad input sets BPM correctly
- [ ] BPM below 30 clamped to 30
- [ ] BPM above 240 clamped to 240
- [ ] Changing BPM while playing updates timing smoothly (no skip or glitch)

### Start/Stop
- [ ] Start begins on beat 1
- [ ] Stop cuts audio cleanly — no hanging click sound
- [ ] Rapid start/stop doesn't crash
- [ ] Beat indicator resets on stop

### Audio Session
- [ ] Audio plays with silent mode switch OFF (muted) — must override silent mode
- [ ] Interruption (phone call) pauses metronome gracefully
- [ ] Audio resumes correctly after interruption ends
- [ ] Other audio apps (Spotify etc) duck/pause correctly

### Visual
- [ ] Beat indicator highlights correct beat in sequence
- [ ] Beat 1 visually distinct from beats 2-4 (accent)
- [ ] Animation timing matches audio (not visually drifting from clicks)

## Simulator Testing Checklist

- [ ] App launches without crash
- [ ] BPM display renders correctly
- [ ] Start/stop button state toggles correctly
- [ ] Beat indicator renders 4 beats
- [ ] BPM input updates displayed value
- [ ] No console errors on launch

## XCTest Patterns

```swift
// WaterGlassTests/MetronomeEngineTests.swift

import XCTest
@testable import Metronome

class MetronomeEngineTests: XCTestCase {

    func testBPMClampedToMinimum() {
        let engine = MetronomeEngine()
        engine.bpm = 10  // below minimum
        XCTAssertEqual(engine.bpm, 30)
    }

    func testBPMClampedToMaximum() {
        let engine = MetronomeEngine()
        engine.bpm = 999
        XCTAssertEqual(engine.bpm, 240)
    }

    func testBeatIntervalAt120BPM() {
        // 120 BPM = 0.5 seconds per beat
        let interval = 60.0 / 120.0
        XCTAssertEqual(interval, 0.5, accuracy: 0.001)
    }
}
```

## Timing Tuning Log

Document timing observations on device:

| BPM | Feels Accurate? | Notes | Date |
|-----|----------------|-------|------|
| 120 | TBD | (initial) | - |
| 60 | TBD | (initial) | - |
| 240 | TBD | (initial) | - |

*Add rows as you test.*

## Common Issues

| Issue | How to Detect | Fix |
|-------|---------------|-----|
| Clicks drift over time | Compare to reference after 2min | Using Timer instead of AVAudioTime — fix scheduling |
| Click on wrong beat | Visual and audio don't match | Beat counter logic off by one |
| Audio cuts out | Silent after a few minutes | AVAudioSession not configured for long playback |
| No audio in silent mode | Phone muted, no clicks | AVAudioSession category not set to `.playback` |
| Crash on rapid BPM change | App terminates on fast BPM tap | Race condition in audio scheduling — add guard |
| Beat indicator lags | Visual behind audio | Callback not on main thread — dispatch to main |

## Lessons Learned

*(add as encountered)*

| Issue | Root Cause | Prevention |
|-------|------------|------------|
| *(add as encountered)* | | |

## Pre-Feature Completion Checklist

- [ ] Builds cleanly
- [ ] Unit tests pass (if any)
- [ ] Tested on simulator (no crash, UI correct)
- [ ] Tested on device (timing accurate, audio correct)
- [ ] Committed with conventional message
- [ ] Pushed to GitHub
- [ ] TASK.md updated
