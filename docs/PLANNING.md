# Metronome iOS - Project Planning

## Project Vision

A native iOS metronome app that looks and feels premium on iOS 26. Clean liquid glass UI,
hardware-accurate beat timing, and the core features a musician actually needs.

Port of the web metronome at https://metronome.jurigregg.com, rebuilt as a proper native
app using SwiftUI and AVAudioEngine.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         iOS APP                                      │
│                    Swift + SwiftUI                                   │
│                    Runs on iPhone                                    │
└─────────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│    MetronomeEngine      │     │      AudioEngine         │
│  BPM, beat state,       │────▶│  AVAudioEngine,          │
│  play/stop logic        │     │  precise scheduling      │
│  (@Observable)          │     │  (hardware clock)        │
└─────────────────────────┘     └─────────────────────────┘
              │
              ▼
┌─────────────────────────┐
│      SwiftUI Views       │
│  ContentView, BPMPad,   │
│  BeatIndicator, etc.    │
└─────────────────────────┘
```

**Data flow:**
```
User taps Start
  → MetronomeEngine.isPlaying = true
  → AudioEngine begins scheduling beats on hardware clock
  → Beat callback fires on each beat
  → MetronomeEngine.currentBeat updates
  → SwiftUI re-renders beat indicator
  → 60fps UI, hardware-accurate audio
```

## No Backend. No Database. No Cloud.

Fully local iOS app. No API calls, no user accounts, no server costs.
BPM preference persisted locally via UserDefaults if desired.

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Language | Swift 5.x | iOS development |
| UI | SwiftUI | Views, layout, animations |
| Audio | AVAudioEngine | Hardware-accurate beat scheduling |
| State | @Observable | Reactive state management |
| IDE | Xcode | Build, run, debug, deploy |
| CLI | Claude Code | AI-assisted implementation |
| Version Control | Git + GitHub | Commit after every feature/fix |

## Project Structure

```
Metronome/
├── MetronomeApp.swift           # App entry point, environment setup
├── ContentView.swift            # Root view
├── Models/
│   └── MetronomeEngine.swift    # BPM, beat state, play/stop (@Observable)
├── Audio/
│   └── AudioEngine.swift        # AVAudioEngine, beat scheduling
├── Views/
│   ├── BPMDisplay.swift         # Large BPM number
│   ├── BPMPad.swift             # Number pad for BPM input
│   ├── BeatIndicator.swift      # 4-beat visual display
│   └── ControlButton.swift      # Start/stop button
└── Assets.xcassets/
```

## Key Concepts

| Concept | Role in Metronome |
|---------|------------------|
| `@Observable` | MetronomeEngine as single source of truth |
| `AVAudioEngine` | Audio graph setup and management |
| `AVAudioPlayerNode` | Schedules individual click sounds |
| `AVAudioTime` | Hardware clock for drift-free scheduling |
| `audioContext.currentTime` equivalent | `AVAudioEngine.outputNode.lastRenderTime` |
| `AVAudioSession` | Category, interruption handling |

## Why AVAudioEngine over Timer

`Timer` and `DispatchQueue.asyncAfter` drift over time — unusable for a metronome.
AVAudioEngine schedules audio buffers on the hardware audio clock, which is independent
of the CPU scheduler and gives sample-accurate timing. Same reason the web version uses
Web Audio API instead of setInterval.

## Development Phases

### Phase 1: Core Metronome
- [ ] MetronomeEngine — BPM (30-240), play/stop, beat counter
- [ ] AudioEngine — click sound, hardware-accurate scheduling
- [ ] Basic SwiftUI layout — BPM display, start/stop button
- [ ] 4-beat visual indicator

**Milestone:** Tap start, hear accurate clicks, see beats highlighted.

### Phase 2: BPM Input
- [ ] Number pad (like web version) for BPM entry
- [ ] Tap tempo — tap the screen to set BPM
- [ ] +/- increment buttons
- [ ] BPM validation (30-240 range)

**Milestone:** All BPM input methods working.

### Phase 3: Polish & iOS 26 UI
- [ ] Liquid glass button styling
- [ ] Beat indicator animations
- [ ] Haptic feedback on beats
- [ ] Dark/light mode
- [ ] App icon

**Milestone:** Looks premium, feels native.

### Phase 4: Extra Features (Optional)
- [ ] Time signatures (3/4, 6/8 etc)
- [ ] Accent on beat 1
- [ ] BPM persistence (UserDefaults)
- [ ] Background audio (keep running when app is backgrounded)

## BPM Range

- Minimum: 30 BPM
- Maximum: 240 BPM
- Default: 120 BPM
- Same as web version

## Success Criteria

1. [ ] Clicks are accurately timed — no drift over 5+ minutes
2. [ ] BPM input is fast and intuitive
3. [ ] Looks native on iOS 26 — liquid glass aesthetic
4. [ ] Handles interruptions gracefully (phone calls, other audio)
5. [ ] Works in silent mode (audio, not just haptic)

## Key Constraints

1. **Hardware-accurate timing** — no Timer-based beat scheduling, ever
2. **500-line file limit** — extract Views and split files early
3. **Commit + push after each feature** — atomic, working commits
4. **Learning project** — favour clarity over cleverness
5. **No force unwraps** — use guard/if let

## Non-Functional Requirements

### Audio
- Beat timing accurate to within 1ms
- Handles AVAudioSession interruptions (calls, other apps)
- Works with silent mode switch off (audio must play — this is a musical tool)

### Performance
- UI runs at 60fps
- Audio scheduling happens off main thread

### Reliability
- No crashes on rapid BPM changes
- No crashes when backgrounding/foregrounding
