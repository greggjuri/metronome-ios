# CLAUDE.md - Claude Code Instructions

This file provides project-specific instructions and conventions for Claude Code.

## Project Overview

**Metronome**: A native iOS metronome app built in SwiftUI. Clean, precise, and polished
with Apple's iOS 26 liquid glass design language.

**Tech Stack**: Swift | SwiftUI | AVAudioEngine | Xcode | iOS 26

## Quick Commands

```bash
# Build for simulator
xcodebuild -scheme Metronome -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run tests
xcodebuild test -scheme Metronome -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Build for device (requires connected iPhone)
xcodebuild -scheme Metronome -destination 'platform=iOS,name=My iPhone' build

# Commit and push (after every feature/fix)
git add .
git commit -m "{type}: {description}"
git push
```

## File Structure

```
Metronome/
├── CLAUDE.md                        # This file
├── docs/
│   ├── PLANNING.md                  # Architecture overview
│   ├── TASK.md                      # Current tasks
│   ├── DECISIONS.md                 # ADRs
│   └── TESTING.md                   # Testing standards
├── initials/                        # Feature specifications: NN-init-{name}.md
├── prps/                            # Implementation plans: NN-prp-{name}.md
│   └── templates/
│       └── prp-template.md
├── .claude/
│   └── commands/
│       ├── generate-prp.md
│       └── execute-prp.md
└── Metronome/                       # Xcode app source
    ├── MetronomeApp.swift
    ├── ContentView.swift
    ├── Models/
    ├── Views/
    ├── Audio/
    └── Assets.xcassets/
```

## File Naming Conventions

- Feature specs: `initials/NN-init-{name}.md` — e.g. `01-init-core-metronome.md`
- Implementation plans: `prps/NN-prp-{name}.md` — e.g. `01-prp-core-metronome.md`
- The `NN` prefix is a zero-padded running number that matches between init and prp
- Use kebab-case for the `{name}` portion

## Critical Rules

### 1. File Size Limit
- **Maximum 500 lines per file**
- Split into separate files/views when approaching limit
- Prefer small focused Views and extracted subcomponents over one giant ContentView

### 2. Commit Strategy
- **Commit AND push after every feature and fix** — no exceptions
- Use conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- Each commit should build successfully

### 3. Testing Requirements
- Run `xcodebuild test` before committing when tests exist
- Audio timing: note in commit that device testing is required
- Add XCTest unit tests for pure logic (BPM calculations, beat sequencing)

### 4. Documentation
- Update `docs/TASK.md` when starting/completing tasks
- Create ADR in `docs/DECISIONS.md` for architectural choices
- Add learnings to `docs/TESTING.md` when debugging issues

## Coding Conventions

### SwiftUI Style

```swift
// MARK: - Use MARK comments to organise large files

// Small, focused Views — extract subviews aggressively
struct BPMDisplay: View {
    let bpm: Int
    var body: some View {
        Text("\(bpm)")
            .font(.system(size: 80, weight: .thin, design: .rounded))
    }
}

// @Observable for state (iOS 17+, preferred over ObservableObject)
@Observable
class MetronomeEngine {
    var bpm: Int = 120
    var isPlaying: Bool = false
}

// @State for local view state
@State private var isPlaying = false

// Environment for shared state
@Environment(MetronomeEngine.self) private var engine
```

### iOS 26 Design Language

```swift
// Liquid glass buttons — use .glassBackgroundEffect() or buttonStyle(.glass)
Button("Start") { }
    .buttonStyle(.glass)

// Materials for backgrounds
.background(.ultraThinMaterial)

// Vibrancy for text on glass
.foregroundStyle(.primary)
```

### Audio Patterns

```swift
// AVAudioEngine for precise scheduling — not Timer or DispatchQueue delays
// Use audioEngine.outputNode and AVAudioPlayerNode
// Schedule beats using audioTime (hardware clock) not wall clock

// Always handle audio session interruptions (phone calls etc)
NotificationCenter.default.addObserver(
    forName: AVAudioSession.interruptionNotification,
    object: nil,
    queue: .main
) { [weak self] notification in
    // handle interruption
}
```

### File Organisation

Split by concern into folders:
- `Models/` — `MetronomeEngine.swift` (BPM, beat state, timing logic)
- `Audio/` — `AudioEngine.swift` (AVAudioEngine setup, beat scheduling)
- `Views/` — individual SwiftUI view files

## Error Handling Patterns

```swift
// Audio session errors — log, present user-facing message if needed
do {
    try AVAudioSession.sharedInstance().setActive(true)
} catch {
    print("Audio session error: \(error.localizedDescription)")
}
```

## PRP Workflow

### Generating PRPs
```bash
/generate-prp initials/NN-init-{name}.md
```
Produces: `prps/NN-prp-{name}.md` — same number prefix as the init file.

### Executing PRPs
```bash
/execute-prp prps/NN-prp-{name}.md
```

## DO NOT

- Commit secrets or provisioning profiles
- Skip the push step after committing
- Create files over 500 lines
- Contradict existing ADRs without discussion
- Use force unwrap (`!`) unless you have a specific reason and comment why
- Use `Timer` or `DispatchQueue.asyncAfter` for beat timing — audio drift is unacceptable
- Use `setInterval`-style timing — this is not a web app

## Reference Documents

- `docs/PLANNING.md` - Architecture and phases
- `docs/DECISIONS.md` - Past decisions to respect
- `docs/TASK.md` - Current work status
- `docs/TESTING.md` - Testing standards
