# init-ui-polish

## Goal

Make the Metronome app look and feel premium on iOS 26. Liquid glass materials on buttons
and controls, beat indicator animations, haptic feedback on every beat, and proper
dark/light mode support. After this PRP the app looks native and intentional, not
like a default scaffold.

---

## Context

Phase 1 and 2 delivered all functionality with placeholder styling (`.borderedProminent`,
plain circles, no haptics). Phase 3 is purely additive — no logic changes, no new features.
Every change is visual or tactile.

---

## Features

### 1. Liquid Glass Styling (iOS 26)

iOS 26 introduces a new "liquid glass" material — translucent, depth-aware, blurred
background. It's applied via `.glassEffect()` modifier (new in iOS 26).

Apply to:
- `ControlButton` (Start/Stop) — large, prominent glass pill
- `BPMPad` digit buttons — glass tiles
- `BPMControls` +/- buttons — glass capsules
- `TapTempoButton` — glass capsule, same family as BPMControls

**Pattern:**
```swift
// iOS 26 glass effect
Button("Start") { ... }
    .padding(.horizontal, 40)
    .padding(.vertical, 16)
    .glassEffect(.regular.interactive())
```

Note: `.glassEffect()` is iOS 26+. Wrap in `if #available(iOS 26, *)` with
`.buttonStyle(.borderedProminent)` fallback for any simulator running older OS.

---

### 2. Beat Indicator Animations

Current: circles change fill colour instantly on beat.

Enhanced:
- **Scale pulse**: active beat circle scales up to 1.3× on hit, springs back to 1.0
- **Glow**: active circle gets a coloured shadow (`.shadow(color: .accentColor, radius: 8)`)
- **Downbeat distinction**: beat 0 circle is slightly larger at rest (1.1× base size) and
  uses a different accent (white or a second accent colour) vs beats 1–3
- **Off animation**: when stopped, all circles fade to resting state with `.easeOut(duration: 0.3)`

```swift
Circle()
    .scaleEffect(isActive ? 1.3 : (isDownbeat ? 1.1 : 1.0))
    .shadow(color: isActive ? .accentColor.opacity(0.8) : .clear, radius: 8)
    .animation(.spring(response: 0.15, dampingFraction: 0.5), value: isActive)
```

---

### 3. Haptic Feedback

Beat 0 (downbeat): heavy impact
Beats 1–3: light impact

```swift
// In MetronomeEngine.beatFired(), on main thread:
let generator = UIImpactFeedbackGenerator(style: beat == 0 ? .heavy : .light)
generator.impactOccurred()
```

Prepare the generator in `start()` to avoid first-beat latency:
```swift
generator.prepare()
```

Store generator as a property on `MetronomeEngine` — don't instantiate on every beat.

---

### 4. BPM Display Polish

- Animate BPM number changes with `.contentTransition(.numericText())`
- Subtle "tap me" hint: a small chevron or underline below the number when stopped

```swift
Text("\(Int(engine.bpm))")
    .contentTransition(.numericText())
    .animation(.default, value: engine.bpm)
```

---

### 5. Start/Stop Button Polish

- Button label transitions: "Start" → "Stop" with a smooth crossfade
- When playing: button tint shifts to a red/stop colour
- Idle pulse animation on the button when stopped (subtle scale 1.0 → 1.02 → 1.0, 2s loop)
  to draw the eye toward the primary action

```swift
Button(engine.isPlaying ? "Stop" : "Start") { ... }
    .tint(engine.isPlaying ? .red : .accentColor)
    .animation(.easeInOut(duration: 0.2), value: engine.isPlaying)
```

---

### 6. Dark / Light Mode

SwiftUI handles most of this automatically. Explicit tasks:
- Verify all custom colours use adaptive `Color` values (no hardcoded hex)
- Beat indicator: use `.primary` / `.secondary` / `.accentColor` — not literal colours
- Test both modes on device — glass effect looks different in each

No new colour assets needed if semantic colours are used throughout.

---

### 7. Layout Refinements

- Add `Spacer()` to vertically centre content on all iPhone sizes
- BPM display and beat indicator: add a subtle `GroupBox` or `RoundedRectangle` background
  with glass material to visually group them
- Safe area padding at bottom for home indicator clearance
- Test on iPhone SE (small) and iPhone Pro Max (large) via simulator

---

## Files to Modify

```
Metronome/Metronome/Views/ControlButton.swift       # MODIFY: glass + animate tint + idle pulse
Metronome/Metronome/Views/BeatIndicator.swift       # MODIFY: spring scale + glow + downbeat
Metronome/Metronome/Views/BPMControls.swift         # MODIFY: glass capsules
Metronome/Metronome/Views/TapTempoButton.swift      # MODIFY: glass capsule
Metronome/Metronome/Views/BPMPad.swift              # MODIFY: glass digit tiles
Metronome/Metronome/Views/BPMDisplay.swift          # MODIFY: numericText transition + tap hint
Metronome/Metronome/Models/MetronomeEngine.swift    # MODIFY: haptic generator + beatFired
Metronome/Metronome/ContentView.swift               # MODIFY: layout spacing + grouping
```

No new files — all changes are modifications.

---

## Technical Notes

### `.glassEffect()` availability

```swift
// At each call site:
if #available(iOS 26, *) {
    button.glassEffect(.regular.interactive())
} else {
    button.buttonStyle(.borderedProminent)
}

// Or as a ViewModifier for reuse:
struct GlassButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.glassEffect(.regular.interactive())
        } else {
            content.buttonStyle(.borderedProminent)
        }
    }
}
```

### Haptic generator lifecycle

Instantiate `UIImpactFeedbackGenerator` once per style, not per beat:

```swift
// In MetronomeEngine:
private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
private let lightHaptic  = UIImpactFeedbackGenerator(style: .light)

// In start():
heavyHaptic.prepare()
lightHaptic.prepare()

// In beatFired():
DispatchQueue.main.async {
    self.currentBeat = beat
    if beat == 0 { self.heavyHaptic.impactOccurred() }
    else          { self.lightHaptic.impactOccurred() }
}
```

### Spring animation tuning

These starting values are reasonable — tune by feel on device:
- Beat pulse: `response: 0.15, dampingFraction: 0.5` (snappy, slight bounce)
- Button tint: `easeInOut(duration: 0.2)` (smooth, not jarring)
- Idle pulse: `easeInOut(duration: 1.0).repeatForever(autoreverses: true)`

---

## Acceptance Criteria

- [ ] Liquid glass styling applied to all interactive buttons
- [ ] Beat indicator pulses and glows on each beat
- [ ] Downbeat (beat 0) visually distinct from beats 1–3
- [ ] Heavy haptic on beat 0, light haptic on beats 1–3
- [ ] BPM number animates on change
- [ ] Start/Stop button changes colour when playing
- [ ] App looks correct in both dark and light mode
- [ ] No hardcoded colours — semantic colours only
- [ ] Layout centred and padded correctly on iPhone SE and iPhone Pro Max
- [ ] All files remain under 500 lines (150 preferred)
- [ ] No force unwraps introduced
- [ ] All Phase 1 and 2 functionality still works

---

## Out of Scope (Phase 4)

- Time signatures
- Accent on beat 1 (separate from downbeat glow)
- BPM persistence (UserDefaults)
- Background audio
- Custom sound selection
- Dracula's Goblet re-skin (wrong project)

---

## Git

Commit message when done: `feat: Phase 3 UI polish — liquid glass, beat animations, haptics`
Push immediately after.
