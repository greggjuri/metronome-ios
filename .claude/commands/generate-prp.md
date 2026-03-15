# Generate PRP

Generate a comprehensive Project Requirement Plan (PRP) for a Metronome iOS feature.

## Arguments
- `$ARGUMENTS` - Path to initial file (e.g., `initials/01-init-core-metronome.md`)

## Instructions

You are generating a PRP for the **Metronome iOS** project — a native iOS metronome app
built in Swift using SwiftUI and AVAudioEngine.

### Step 1: Gather Context

Read and internalize the following project documentation:
1. `CLAUDE.md` — Coding conventions, Swift patterns, commit rules
2. `docs/PLANNING.md` — Architecture, phases, tech stack
3. `docs/DECISIONS.md` — Past ADRs (don't contradict these)
4. `docs/TASK.md` — Current task status
5. `docs/TESTING.md` — Testing standards and device testing requirements

### Step 2: Read the Initial File

Read the initial specification at `$ARGUMENTS`:
1. Understand the feature requirements
2. Note phase (1/2/3/4) and dependencies
3. Identify SwiftUI/AVAudioEngine integration points
4. Confirm all open questions are answered

### Step 3: Research Codebase

Based on the feature, research existing code:
1. Read current `Metronome/` Swift files
2. Identify files that need modification vs new files to create
3. Check if file size limit is being approached (300 lines = split warning)
4. Note existing patterns to follow

### Step 4: Generate PRP

**Naming rule**: The PRP filename uses the same running number as the init file.
- Input:  `initials/NN-init-{name}.md`
- Output: `prps/NN-prp-{name}.md`
- Example: `initials/01-init-core-metronome.md` → `prps/01-prp-core-metronome.md`

Use the template at `prps/templates/prp-template.md` as the structure.

Fill in all sections:
1. **Overview**: Clear problem statement and proposed solution
2. **Success Criteria**: Observable and testable outcomes
3. **Context**: Relevant ADRs, files to modify/create
4. **Technical Specification**: Swift types, SwiftUI views, audio architecture
5. **Implementation Steps**: Ordered, atomic tasks with exact file paths
6. **Testing Requirements**: Simulator check + device audio testing checklist
7. **Error Handling**: AVAudioSession interruptions, BPM edge cases
8. **Open Questions**: Anything unclear
9. **Rollback Plan**: git revert steps

### Step 5: Score Confidence

Score confidence (1-10) on each dimension:
- **Clarity**: Are requirements unambiguous?
- **Feasibility**: Achievable with SwiftUI + AVAudioEngine?
- **Completeness**: No missing pieces?
- **Alignment**: Follows ADRs and constraints?

If average < 7:
- List specific concerns
- Do NOT proceed until concerns are addressed

### Step 6: Output

1. Create the PRP file in `prps/`
2. Report the file path created
3. Display confidence scores
4. List any open questions or concerns

## Example Usage

```
/generate-prp initials/01-init-core-metronome.md
```
→ Creates `prps/01-prp-core-metronome.md`

## Quality Checklist

Before completing, verify:
- [ ] PRP filename matches init number prefix
- [ ] Every implementation step has specific Swift file paths
- [ ] Steps are atomic and individually buildable
- [ ] Device audio testing checklist is specific
- [ ] AVAudioSession setup and interruption handling covered
- [ ] No ADRs are contradicted
- [ ] Commit + push step is the final implementation step
- [ ] Rollback plan uses git revert
