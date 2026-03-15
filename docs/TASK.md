# Metronome iOS - Task Tracker

## Current Sprint: Phase 1 — Core Metronome

### In Progress

*(none)*

### Up Next

*(none for Phase 1)*

---

## Recently Completed

- [x] `01-init-core-metronome.md` - MetronomeEngine, AudioEngine, basic UI, beat indicator (2026-03-14)
- [x] Project setup and scaffold (2026-03-14)

---

## Backlog

### Phase 1 - Core Metronome
- [x] `01-init-core-metronome.md` - BPM state, click audio, start/stop, 4-beat indicator ✓

### Phase 2 - BPM Input
- [ ] `02-init-bpm-input.md` - Number pad, tap tempo, +/- buttons

### Phase 3 - Polish & iOS 26 UI
- [ ] `03-init-ui-polish.md` - Liquid glass styling, animations, haptics, dark/light mode

### Phase 4 - Extra Features (Optional)
- [ ] `04-init-extras.md` - Time signatures, accent, persistence, background audio

---

## Completed

*(updated as features ship)*

---

## Architecture Decisions

*(see docs/DECISIONS.md for full ADRs)*

---

## Notes

### Audio Testing
- Simulator: UI and layout only — audio works but timing is unreliable
- Physical device: required for all timing accuracy testing
- Test timing drift over 5+ minutes on device

### Known Issues
- *(none yet)*

---

*Last updated: 2026-03-14 (Phase 1 core metronome complete — pending device testing)*

---

**Task Status Flow:**
```
Backlog → Up Next → In Progress → Recently Completed → Completed
```
