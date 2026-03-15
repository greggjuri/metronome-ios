# Execute PRP

Execute a Project Requirement Plan step-by-step for Metronome iOS.

## Arguments
- `$ARGUMENTS` - Path to PRP file (e.g., `prps/01-prp-core-metronome.md`)

## Instructions

You are executing a PRP for the **Metronome iOS** project — a Swift/SwiftUI/AVAudioEngine app.

### Step 0: Pre-flight Checks

Before starting:
1. Read `CLAUDE.md` for Swift conventions and commit rules
2. Read the PRP at `$ARGUMENTS` completely
3. Verify all dependencies are met
4. Check that confidence score is ≥ 7 (if not, stop and report concerns)
5. Confirm you understand the success criteria

### Step 1: Execute Implementation Steps

For each implementation step in the PRP:

1. **Announce**: State which step you're starting
2. **Implement**: Write the Swift/SwiftUI code
3. **Follow conventions**: @Observable, guard for optionals, MARK comments, weak self in closures
4. **Validate**: Build after each step
5. **Commit and push**: After each step validates

```bash
# Build check after each step
xcodebuild -scheme Metronome \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build

# Commit and push after validation
git add .
git commit -m "{type}: {description}"
git push
```

### Step 2: Handle Failures

If a build fails:
1. **Read the error**: Swift/Xcode errors are usually precise
2. **Fix**: Make minimal changes to resolve
3. **Document**: Note the issue in commit message if interesting
4. **Continue**: Only proceed when build succeeds

If unable to proceed:
1. Report the blocker clearly
2. Suggest potential solutions
3. Ask for guidance before continuing

### Step 3: Simulator Validation

After all implementation steps build cleanly:

1. Verify: app launches, UI renders, no console errors
2. Test state changes: BPM input updates display, start/stop toggles correctly
3. Note: audio timing accuracy requires device — simulator timing is unreliable
4. Record: "Simulator check passed — device testing required for timing accuracy"

### Step 4: Flag Device Testing Required

```
⚠️  DEVICE TESTING REQUIRED

The following must be verified on a physical iPhone:
- [list audio/timing criteria from PRP device test checklist]

Key things to check:
- Clicks are evenly timed at multiple BPMs
- No drift after 2+ minutes
- Audio plays with silent mode switch off
- AVAudioSession handles interruptions correctly
```

### Step 5: Update Documentation

1. Update `docs/TASK.md`:
   - Move task from "In Progress" to "Recently Completed"

2. If architectural decisions were made:
   - Add ADR to `docs/DECISIONS.md`

3. If timing behaviour was observed on device:
   - Update the Timing Tuning Log in `docs/TESTING.md`

### Step 6: Report Completion

```
## PRP Execution Complete

**PRP**: prps/NN-prp-{name}.md
**Status**: Complete (pending device testing) / Partial / Blocked

### Commits Made
- {commit hash}: {message}

### Build Status
- Simulator: ✅ Builds and launches
- Device: ⚠️ Not yet tested — timing accuracy requires physical iPhone

### Success Criteria
- [x] Criterion 1 (verified simulator)
- [ ] Criterion 2 — requires device (timing accuracy)

### Device Testing Checklist
{Paste the device test checklist from the PRP}
```

## Commit Message Format

```
feat: add MetronomeEngine with BPM state and play/stop
feat: add AudioEngine with AVAudioEngine beat scheduling
fix: clamp BPM to 30-240 range on input
refactor: extract BeatIndicator into separate View file
docs: update TASK.md with Phase 1 completion
test: add BPM range validation unit tests
```

## Quality Standards

- **No file over 500 lines**: Extract Views and split files
- **No force unwraps**: Use guard/if let
- **Working commits**: Each commit must build
- **Always push**: Never commit without pushing
- **No Timer for beats**: AVAudioEngine hardware clock only

## Emergency Stop

Stop and report before proceeding if you encounter:
- Contradicting an existing ADR
- A timing approach that uses Timer or DispatchQueue for beat scheduling
- Unclear requirements about audio behaviour
- A build error you cannot resolve
