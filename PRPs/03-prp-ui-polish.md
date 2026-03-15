# 03-prp-ui-polish: Phase 3 UI Polish

**Created**: 2026-03-14
**Initial**: `INITs/03-init-ui-polish.md`
**Status**: Draft

---

## Overview

### Problem Statement

Phase 1 and 2 delivered all core functionality with placeholder styling — `.borderedProminent` buttons, plain circles, no haptics. The app works but looks like a default scaffold, not a polished iOS 26 app.

### Proposed Solution

Purely visual/tactile changes — no logic changes, no new features:

1. **Liquid glass** styling on all interactive buttons via `.glassEffect()` (iOS 26)
2. **Beat indicator animations** — scale pulse, glow shadow, spring animation
3. **Haptic feedback** — heavy impact on downbeat, light on beats 1–3
4. **BPM display polish** — numeric text transition, tap hint
5. **Start/Stop button** — colour shift when playing, label crossfade
6. **Dark/light mode** — verify semantic colours throughout
7. **Layout refinements** — vertical centering, safe area padding, visual grouping

### Success Criteria

- [ ] Liquid glass styling on all interactive buttons (ControlButton, BPMPad, BPMControls, TapTempo)
- [ ] Beat indicator pulses (1.3× scale) and glows on each beat
- [ ] Downbeat (beat 0) visually distinct from beats 1–3
- [ ] Heavy haptic on beat 0, light haptic on beats 1–3
- [ ] BPM number animates on change (`.contentTransition(.numericText())`)
- [ ] Start/Stop button changes tint to red when playing
- [ ] App looks correct in both dark and light mode
- [ ] No hardcoded colours — semantic colours only
- [ ] Layout centred and padded on iPhone SE and Pro Max
- [ ] All files under 500 lines (150 preferred)
- [ ] No force unwraps
- [ ] All Phase 1 and 2 functionality still works

---

## Context

### Related Documentation

- `docs/PLANNING.md` — Phase 3 scope
- `docs/DECISIONS.md` — ADR-001 (SwiftUI), ADR-002 (AVAudioEngine), ADR-003 (@Observable)
- `docs/TESTING.md` — Device testing checklist

### Dependencies

- **Required**: Phase 1 and Phase 2 complete — done
- **Optional**: None

### Files to Modify/Create

```
Metronome/Metronome/Views/BeatIndicator.swift       # MODIFY: spring scale + glow + downbeat
Metronome/Metronome/Views/ControlButton.swift       # MODIFY: glass + tint + idle pulse
Metronome/Metronome/Views/BPMDisplay.swift          # MODIFY: numericText transition + tap hint
Metronome/Metronome/Views/BPMPad.swift              # MODIFY: glass digit tiles
Metronome/Metronome/Views/BPMControls.swift         # MODIFY: glass capsules
Metronome/Metronome/Views/TapTempoButton.swift      # MODIFY: glass capsule
Metronome/Metronome/Models/MetronomeEngine.swift    # MODIFY: haptic generators + beatFired
Metronome/Metronome/ContentView.swift               # MODIFY: layout spacing + grouping + padding
```

No new files — all changes are modifications to existing files.

---

## Technical Specification

### Liquid Glass Pattern

`.glassEffect()` is iOS 26+. Since deployment target is iOS 26.2, no fallback needed — use directly.

```swift
// Apply to buttons — replace .buttonStyle(.borderedProminent) / .buttonStyle(.bordered)
Button { ... } label: {
    Text("Start")
        .font(.title2)
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
}
.glassEffect(.regular.interactive())
```

Remove existing `.buttonStyle(...)` calls and replace with `.glassEffect(.regular.interactive())`.

### Beat Indicator Enhancements

```swift
Circle()
    .fill(fillColor(for: beat))
    .frame(width: baseSize(for: beat), height: baseSize(for: beat))
    .scaleEffect(isActive(beat) ? 1.3 : 1.0)
    .shadow(color: isActive(beat) ? .accentColor.opacity(0.8) : .clear, radius: 8)
    .animation(.spring(response: 0.15, dampingFraction: 0.5), value: currentBeat)
```

- Active beat: 1.3× scale, accent glow shadow
- Downbeat at rest: slightly larger base size (20pt vs 16pt) — already done
- Stopped state: fade to resting with `.easeOut(duration: 0.3)`

### Haptic Feedback in MetronomeEngine

```swift
import UIKit  // for UIImpactFeedbackGenerator

// Properties:
private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
private let lightHaptic = UIImpactFeedbackGenerator(style: .light)

// In start():
heavyHaptic.prepare()
lightHaptic.prepare()

// In beatFired():
DispatchQueue.main.async { [weak self] in
    guard let self else { return }
    self.currentBeat = beat
    if beat == 0 { self.heavyHaptic.impactOccurred() }
    else         { self.lightHaptic.impactOccurred() }
}
```

### BPM Display Polish

```swift
Text("\(Int(engine.bpm))")
    .contentTransition(.numericText())
    .animation(.default, value: engine.bpm)

// Tap hint when stopped
if !engine.isPlaying {
    Text("tap to edit")
        .font(.caption2)
        .foregroundStyle(.tertiary)
}
```

### Start/Stop Button Polish

```swift
Button { ... } label: {
    Text(engine.isPlaying ? "Stop" : "Start")
        .font(.title2)
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
        .contentTransition(.symbolEffect(.replace))
}
.tint(engine.isPlaying ? .red : .accentColor)
.glassEffect(.regular.interactive())
.animation(.easeInOut(duration: 0.2), value: engine.isPlaying)
```

### ContentView Layout

```swift
VStack(spacing: 40) {
    Spacer()
    BeatIndicator(...)
    BPMDisplay()
    BPMControls()
    TapTempoButton()
    ControlButton(...)
    Spacer()
}
.padding(.bottom)  // safe area clearance
```

---

## Implementation Steps

### Step 1: Add haptic feedback to MetronomeEngine

**Files**: `Metronome/Metronome/Models/MetronomeEngine.swift` (modify)

- Add `import UIKit`
- Add `heavyHaptic` and `lightHaptic` generator properties
- Call `.prepare()` in `start()`
- Fire appropriate haptic in `beatFired()` on main thread

**Validation**:
- [ ] Builds without errors

---

### Step 2: Enhance BeatIndicator animations

**Files**: `Metronome/Metronome/Views/BeatIndicator.swift` (modify)

- Add scale effect (1.3× on active beat)
- Add glow shadow on active beat
- Replace animation with `.spring(response: 0.15, dampingFraction: 0.5)`
- Add stopped-state fade animation

**Validation**:
- [ ] Builds without errors
- [ ] Preview renders pulse states

---

### Step 3: Polish BPMDisplay

**Files**: `Metronome/Metronome/Views/BPMDisplay.swift` (modify)

- Add `.contentTransition(.numericText())` and `.animation(.default, value: engine.bpm)`
- Add "tap to edit" hint text when stopped

**Validation**:
- [ ] Builds without errors

---

### Step 4: Glass + polish on ControlButton

**Files**: `Metronome/Metronome/Views/ControlButton.swift` (modify)

- Replace `.buttonStyle(.borderedProminent)` with `.glassEffect(.regular.interactive())`
- Add `.tint()` colour shift (red when playing, accent when stopped)
- Widen padding for glass pill shape
- Add `.animation()` on `isPlaying` value
- ControlButton needs access to `isPlaying` for tint — already has it as a prop

**Validation**:
- [ ] Builds without errors

---

### Step 5: Glass on BPMControls

**Files**: `Metronome/Metronome/Views/BPMControls.swift` (modify)

- Replace `.buttonStyle(.bordered)` with `.glassEffect(.regular.interactive())`
- Adjust padding for glass capsule appearance

**Validation**:
- [ ] Builds without errors

---

### Step 6: Glass on TapTempoButton

**Files**: `Metronome/Metronome/Views/TapTempoButton.swift` (modify)

- Replace `.buttonStyle(.bordered)` with `.glassEffect(.regular.interactive())`
- Adjust padding for glass capsule

**Validation**:
- [ ] Builds without errors

---

### Step 7: Glass on BPMPad

**Files**: `Metronome/Metronome/Views/BPMPad.swift` (modify)

- Replace `.buttonStyle(.bordered)` on digit buttons with `.glassEffect(.regular.interactive())`
- Replace `.buttonStyle(.borderedProminent)` on confirm button with `.glassEffect(.regular.interactive())`
- Keep cancel button tint red

**Validation**:
- [ ] Builds without errors

---

### Step 8: Layout refinements in ContentView

**Files**: `Metronome/Metronome/ContentView.swift` (modify)

- Add `Spacer()` top and bottom for vertical centering
- Add `.padding(.bottom)` for safe area clearance
- Verify spacing works on different screen sizes

**Validation**:
- [ ] Builds without errors
- [ ] App launches on simulator
- [ ] All controls visible and centred

---

### Step 9: Build and verify

```bash
xcodebuild -project Metronome/Metronome.xcodeproj -scheme Metronome \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Verify:
- [ ] Clean build
- [ ] No hardcoded colours (check all view files)
- [ ] All files under 150 lines
- [ ] All Phase 1/2 functionality intact

---

### Step 10: Commit and push

```bash
git add .
git commit -m "feat: Phase 3 UI polish — liquid glass, beat animations, haptics"
git push
```

Update `docs/TASK.md`

**Validation**:
- [ ] Commit pushed to GitHub
- [ ] `docs/TASK.md` updated

---

## Testing Requirements

### Simulator Tests

- [ ] App launches without crash
- [ ] Beat indicator circles visible with correct sizing
- [ ] BPM display animates on value change (via +/- buttons)
- [ ] "tap to edit" hint visible when stopped
- [ ] Start/Stop button tint changes
- [ ] Glass effect renders on buttons (iOS 26 simulator)
- [ ] All controls still functional (pad, tap tempo, +/-, start/stop)

### Device Tests

| # | Action | Expected Result | Pass? |
|---|--------|-----------------|-------|
| 1 | Tap Start | Heavy haptic on beat 0, light on beats 1–3 | ☐ |
| 2 | Watch beat indicator | Circles pulse (scale up) and glow on beat | ☐ |
| 3 | Change BPM via +/- | Number animates smoothly | ☐ |
| 4 | Tap Start | Button tint shifts to red | ☐ |
| 5 | Switch to dark mode | All elements visible, glass adapts | ☐ |
| 6 | Switch to light mode | All elements visible, glass adapts | ☐ |
| 7 | Open BPM pad | Glass tiles on digit buttons | ☐ |
| 8 | Run on iPhone SE size | Layout centred, no clipping | ☐ |
| 9 | Run on Pro Max size | Layout centred, good spacing | ☐ |
| 10 | Play for 2 minutes | Haptics continue, no drift, animations smooth | ☐ |

---

## Error Handling

| Error | Cause | Handling |
|-------|-------|----------|
| `.glassEffect()` not available | Running on pre-iOS 26 | Not applicable — deployment target is iOS 26.2 |
| Haptic generator failure | Device doesn't support haptics (simulator) | `UIImpactFeedbackGenerator` silently no-ops on simulator |
| Animation jank | Too many simultaneous animations | Spring animation is lightweight; monitor on device |

---

## Open Questions

- None — the init spec is comprehensive with code examples for each visual change.

---

## Rollback Plan

If issues are discovered:
1. `git revert <commit-hash>` to undo the Phase 3 commit
2. `git push` to update remote
3. Verify: Phase 1+2 functionality intact with original styling

---

## Confidence Scores

| Dimension | Score (1-10) | Notes |
|-----------|--------------|-------|
| Clarity | 9 | Init spec includes SwiftUI code snippets for every change |
| Feasibility | 8 | `.glassEffect()` is new iOS 26 API — needs device verification |
| Completeness | 9 | All visual changes specified with exact modifiers |
| Alignment | 10 | No logic changes, no ADR conflicts |
| **Average** | **9.0** | Ready for execution |

---

## Notes

- `.glassEffect()` is iOS 26+ only. Since deployment target is iOS 26.2, no `#available` check needed.
- Haptic generators are instantiated once as properties, not per-beat — avoids allocation overhead.
- `heavyHaptic.prepare()` is called in `start()` to prime the Taptic Engine before the first beat fires.
- All colour usage should be semantic (`Color.primary`, `.secondary`, `.accentColor`) — no hex values.
- The idle pulse animation on ControlButton (subtle 1.0→1.02 breathing) is mentioned in the init but is low-priority. Include if it looks good, skip if it adds visual noise.
- Spring animation values (`response: 0.15, dampingFraction: 0.5`) are starting points — tune on device.
