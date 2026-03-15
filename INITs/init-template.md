# Init Template - Feature Specification

## NN-init-{name}: {Feature Name}

**Created**: {YYYY-MM-DD}
**Priority**: {High/Medium/Low}
**Phase**: {1 / 2 / 3 / 4}
**Depends On**: {NN-init-{name}, or "None"}

---

## Problem Statement

{What problem does this feature solve? What's missing or broken? 1-3 sentences.}

## Goal

{What will be true when this feature is complete? What can you hear/see/feel on device?}

## Requirements

### Must Have (P0)
1. {Requirement 1}
2. {Requirement 2}
3. {Requirement 3}

### Should Have (P1)
1. {Requirement 4}

### Nice to Have (P2)
1. {Requirement 5}

## Technical Considerations

### SwiftUI Changes
- {New Views needed}
- {State changes — @Observable properties}
- {Changes to existing views}

### Audio Changes
- {AVAudioEngine changes, if applicable}
- {New sounds, scheduling changes}

### New Files
- {e.g., `Metronome/Views/BeatIndicator.swift` — new view}
- {e.g., `Metronome/Audio/AudioEngine.swift` — new audio class}

### State / Data
- {New properties on MetronomeEngine}
- {UserDefaults keys if persistence needed}

## Constraints

- {e.g., Must not use Timer for beat scheduling}
- {e.g., Must handle AVAudioSession interruptions}
- {e.g., Must maintain 60fps UI}

## Success Criteria

- [ ] {Testable criterion 1 — observable on device}
- [ ] {Testable criterion 2}
- [ ] {Testable criterion 3}

## Out of Scope

- {Not included 1}
- {Not included 2}

## Open Questions

- [ ] {Question 1 — answer before generating PRP}
- [ ] {Question 2}

## Notes

{Any additional context, Apple documentation references, audio timing notes, etc.}

---

## Usage

1. Copy to `initials/NN-init-{name}.md` — use the next available running number
2. Fill in all sections
3. Answer all Open Questions before generating PRP
4. Then in Claude Code: `/generate-prp initials/NN-init-{name}.md`
   → Produces: `prps/NN-prp-{name}.md` (same number prefix)
