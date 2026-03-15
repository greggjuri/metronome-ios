# metronome-ios

Native iOS metronome app built in SwiftUI. Port of [metronome.jurigregg.com](https://metronome.jurigregg.com).

Hardware-accurate beat timing, liquid glass iOS 26 UI, and the core features a musician actually needs.

## Features

- **BPM Control**: 30–240 BPM range with number pad and tap tempo
- **Visual Beat Counter**: 4-beat display with active beat highlighting
- **Precise Timing**: AVAudioEngine hardware clock — no drift
- **Start/Stop**: On-screen button
- **iOS 26 Design**: Liquid glass aesthetic, dark/light mode

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift |
| UI | SwiftUI |
| Audio | AVAudioEngine |
| State | @Observable |
| IDE | Xcode |

## Project Structure

```
Metronome/
├── MetronomeApp.swift
├── ContentView.swift
├── Models/
│   └── MetronomeEngine.swift    # BPM, beat state, play/stop
├── Audio/
│   └── AudioEngine.swift        # AVAudioEngine, beat scheduling
├── Views/
│   ├── BPMDisplay.swift
│   ├── BPMPad.swift
│   ├── BeatIndicator.swift
│   └── ControlButton.swift
└── Assets.xcassets/
```

## Development Workflow

Uses context engineering with Claude Code:

1. Write init spec: `initials/NN-init-{name}.md`
2. Generate PRP: `/generate-prp initials/NN-init-{name}.md`
3. Review PRP in Claude.ai
4. Execute: `/execute-prp prps/NN-prp-{name}.md`

See `docs/PLANNING.md` for architecture and phases.
See `docs/DECISIONS.md` for architecture decisions.

## Requirements

- iOS 26+
- iPhone (physical device required for timing accuracy testing)
- Xcode 26+

## Notes

- Disable silent mode switch for audio to play — AVAudioSession overrides silent mode
- Audio timing uses AVAudioEngine hardware clock, same principle as Web Audio API
- Simulator builds work for UI testing; timing accuracy requires physical device
