# PRP Template

## NN-prp-{name}: {Feature Name}

**Created**: {YYYY-MM-DD}
**Initial**: `initials/NN-init-{name}.md`
**Status**: Draft/Ready/In Progress/Complete

---

## Overview

### Problem Statement
{What problem are we solving? Copy/adapt from init.}

### Proposed Solution
{High-level description of what we're building and how.}

### Success Criteria
- [ ] {Criterion 1 — observable/testable}
- [ ] {Criterion 2}
- [ ] {Criterion 3}

---

## Context

### Related Documentation
- `docs/PLANNING.md` — Architecture overview
- `docs/DECISIONS.md` — Relevant ADRs: {list specific ones}
- `docs/TESTING.md` — Device testing checklist

### Dependencies
- **Required**: {PRPs/features that must be complete first, or "None"}
- **Optional**: {Features that enhance but aren't required}

### Files to Modify/Create
```
Metronome/Models/MetronomeEngine.swift    # Description of changes
Metronome/Audio/AudioEngine.swift         # NEW: AVAudioEngine scheduling
Metronome/Views/BeatIndicator.swift       # NEW: 4-beat visual
Metronome/ContentView.swift               # Wire up views and engine
```

---

## Technical Specification

### New Swift Types
```swift
// Example
@Observable
class MetronomeEngine {
    var bpm: Int = 120
    var isPlaying: Bool = false
    var currentBeat: Int = 0
}
```

### View Hierarchy
```
ContentView
├── BPMDisplay          # Large BPM number
├── BeatIndicator       # 4 beat dots/squares
├── BPMPad              # Number input
└── ControlButton       # Start/Stop
```

### Audio Architecture
{Describe how AVAudioEngine is set up and how beats are scheduled}

```swift
// Example scheduling pattern
func scheduleBeat(at time: AVAudioTime) {
    playerNode.scheduleBuffer(clickBuffer, at: time, options: []) {
        // schedule next beat from completion handler
    }
}
```

---

## Implementation Steps

### Step 1: {First Step Title}
**Files**: `Metronome/Models/MetronomeEngine.swift` (new)

{Detailed description}

```swift
// Code example
```

**Validation**:
- [ ] Builds without errors
- [ ] {Specific check}

---

### Step 2: {Second Step Title}
**Files**: `Metronome/Audio/AudioEngine.swift` (new)

{Detailed description}

**Validation**:
- [ ] Builds without errors
- [ ] Launches on simulator without crash

---

### Step N: Commit and Push
```bash
git add .
git commit -m "feat: {description}"
git push
```

**Validation**:
- [ ] Commit pushed to GitHub
- [ ] `docs/TASK.md` updated

---

## Testing Requirements

### Unit Tests (if applicable)
- `testBPMClampedToMinimum`: BPM below 30 → clamped to 30
- `testBPMClampedToMaximum`: BPM above 240 → clamped to 240
- `testBeatInterval`: Correct seconds-per-beat calculation

### Simulator Tests
- [ ] App launches without crash
- [ ] BPM display shows correct value
- [ ] Start/stop toggles correctly
- [ ] Beat indicator renders

### Device Tests

| # | Action | Expected Result | Pass? |
|---|--------|-----------------|-------|
| 1 | Launch app | UI renders, ready to play | ☐ |
| 2 | Tap Start at 120 BPM | Clicks at 1 per 0.5 seconds | ☐ |
| 3 | Listen for 2 minutes | No audible drift | ☐ |
| 4 | Change BPM while playing | Timing updates smoothly | ☐ |
| 5 | Tap Stop | Clicks stop cleanly | ☐ |
| 6 | Silent mode switch | Audio still plays | ☐ |

### Error Scenarios
| Scenario | How to Trigger | Expected Behavior | Pass? |
|----------|----------------|-------------------|-------|
| Phone call while playing | Receive call | Metronome pauses gracefully | ☐ |
| BPM set to 0 | Enter 0 in pad | Clamped to 30, no crash | ☐ |

---

## Error Handling

| Error | Cause | Handling |
|-------|-------|----------|
| AVAudioSession activation failure | Audio hardware busy | Log error, show user message |
| AVAudioEngine start failure | System audio error | Log, attempt restart |
| Interruption (call) | Incoming call | Stop playback, resume on end if appropriate |

---

## Open Questions

- [ ] {Question 1 — must be answered before execution}

---

## Rollback Plan

If issues are discovered:
1. `git revert {commit-hash}` to undo
2. `git push` to update remote
3. Verify: build succeeds, app launches

---

## Confidence Scores

| Dimension | Score (1-10) | Notes |
|-----------|--------------|-------|
| Clarity | X | |
| Feasibility | X | |
| Completeness | X | |
| Alignment | X | |
| **Average** | **X** | |

---

## Notes

{Additional context, Apple audio docs references, timing implementation notes, etc.}
