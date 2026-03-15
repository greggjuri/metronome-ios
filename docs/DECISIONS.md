# Metronome iOS - Architecture Decisions

## ADR-001: SwiftUI for UI

**Date**: 2026-03-14
**Status**: Accepted

### Context
Need a UI framework for iOS. Options: SwiftUI, UIKit, or hybrid.

### Decision
Use SwiftUI throughout.

### Rationale
- Native iOS 26 — liquid glass and new design language are SwiftUI-first
- Declarative — easier to reason about for a learning project
- `@Observable` macro makes state management clean
- No reason to use UIKit for a simple single-screen app

### Consequences
**Positive:**
- iOS 26 design system works out of the box
- Less boilerplate than UIKit

**Negative:**
- Some advanced audio UI patterns have less community documentation than UIKit

---

## ADR-002: AVAudioEngine for Beat Scheduling

**Date**: 2026-03-14
**Status**: Accepted

### Context
Need accurate beat timing. Options: Timer, DispatchQueue, AVAudioEngine, AVAudioPlayer.

### Decision
Use `AVAudioEngine` with `AVAudioPlayerNode` scheduled on the hardware audio clock.

### Rationale
- `Timer` and `DispatchQueue.asyncAfter` drift — unusable for a metronome
- `AVAudioEngine` schedules on the hardware clock (`AVAudioTime`) — sample-accurate
- Same principle as the web version's Web Audio API scheduler
- Industry standard approach for iOS metronome apps

### Alternatives Considered
| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| AVAudioEngine | Hardware clock, no drift | More setup | **Selected** |
| Timer | Simple | Drifts — unusable | Rejected |
| DispatchQueue | Simple | Drifts — unusable | Rejected |
| AVAudioPlayer | Simple | No hardware scheduling | Rejected |

### Consequences
**Positive:**
- Beat timing accurate to within ~1ms
- Robust under CPU load

**Negative:**
- More complex setup than a simple Timer
- Must handle AVAudioSession lifecycle carefully

---

## ADR-003: @Observable for State Management

**Date**: 2026-03-14
**Status**: Accepted

### Context
Need reactive state that SwiftUI views can observe. Options: @Observable (iOS 17+),
ObservableObject/Published, or manual state passing.

### Decision
Use `@Observable` macro on `MetronomeEngine`.

### Rationale
- iOS 17+ / iOS 26 target — @Observable is the modern approach
- Less boilerplate than ObservableObject + @Published
- Automatic observation — only views that read a property re-render when it changes
- Clean and idiomatic for a new Swift project

### Consequences
**Positive:**
- Minimal boilerplate
- Precise re-rendering

**Negative:**
- iOS 17+ only (acceptable — we target iOS 26)

---

## ADR-004: Separate MetronomeEngine and AudioEngine

**Date**: 2026-03-14
**Status**: Accepted

### Context
Beat state/logic and audio scheduling are distinct concerns. Could be one class or two.

### Decision
Split into:
- `MetronomeEngine` — BPM value, isPlaying state, currentBeat, play/stop logic
- `AudioEngine` — AVAudioEngine setup, buffer loading, beat scheduling

### Rationale
- Single responsibility — state management vs audio hardware
- AudioEngine can be tested/swapped independently
- MetronomeEngine is the public API; AudioEngine is an implementation detail
- Keeps both files under 500 lines easily

### Consequences
**Positive:**
- Clear separation of concerns
- Each file stays small and focused

**Negative:**
- Slight coordination overhead (minor)

---

## Template for New Decisions

```markdown
## ADR-XXX: Title

**Date**: YYYY-MM-DD
**Status**: Proposed/Accepted/Deprecated/Superseded

### Context
What is the issue motivating this decision?

### Decision
What are we doing?

### Rationale
Why is this the best choice?

### Alternatives Considered (optional)
| Option | Pros | Cons | Verdict |
|--------|------|------|---------|

### Consequences
**Positive:**
- Benefit 1

**Negative:**
- Tradeoff 1
```

## Key Principles

1. **SwiftUI throughout** — no UIKit unless absolutely necessary
2. **Hardware clock for audio** — never Timer or DispatchQueue for beats
3. **@Observable for state** — single source of truth in MetronomeEngine
4. **Split by concern** — Models/, Audio/, Views/ folder structure
