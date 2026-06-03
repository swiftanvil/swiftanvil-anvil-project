# SwiftAnvil Orchestration Framework

> Agent-agnostic multi-phase build system. Any model can be the builder. Any *different* model can be the reviewer.

---

## 🎯 Core Principle

**No agent is special.** The framework works identically whether the primary builder is Kimi, Claude, GPT-4, or any future model. The reviewer is always a *different* model from the builder.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Primary Builder (Any Model)                     │
│  - Plans, implements, tests, documents                       │
│  - Can be Kimi, Claude, GPT-4, Gemini, etc.                │
├─────────────────────────────────────────────────────────────┤
│  Phase N: [Active Phase]                                     │
│  ├── Child N.1: [Task]                                       │
│  ├── Child N.2: [Task]                                       │
│  └── ...                                                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│           Cross-Host Reviewer (Different Model)              │
│  - Must be a DIFFERENT model from the builder               │
│  - Reviews all deliverables                                  │
│  - Provides feedback on code quality                         │
│  - Suggests improvements                                     │
│  - Approves phase gates                                      │
└─────────────────────────────────────────────────────────────┘
```

### Model Rotation Rule

| Session | Primary Builder | Cross-Host Reviewer | How Decided |
|---------|----------------|---------------------|-------------|
| 1 | Kimi | Claude | User picks, or random |
| 2 | Claude | GPT-4 | Must differ from builder |
| 3 | GPT-4 | Kimi | Must differ from builder |
| 4 | Kimi | GPT-4 | Rotate to avoid bias |

**Hard rule:** The reviewer model MUST be different from the builder model. No self-review.

---

## 🔄 Per-Child Workflow (5 Steps)

Every child follows this exact sequence. **No skipping steps. No faking reviews.**

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  PLAN   │───→│ REVIEW  │───→│ EXECUTE │───→│ VERIFY  │───→│DOCUMENT │
│ (Build) │    │(Cross)  │    │ (Build) │    │(Cross)  │    │ (Build) │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
     │              │              │              │              │
     ▼              ▼              ▼              ▼              ▼
 PLAN.md      REVIEW.md      Code+Tests     REVIEW.md      RESULT.md
                                                    +         roadmap.org
                                              (append)       checklist.legacy
```

### 🔒 Cross-Host Review Lock

**Before ANY child can advance past Step 4, the builder MUST:**

1. **Attempt cross-host review** — Run the review command(s) and capture output
2. **Save the review artifact** — Write `Children/{id}/REVIEW-IMPL.md` with the actual reviewer output
3. **If the reviewer says NEEDS_REVISION** — Fix blockers, re-run review, save new artifact
4. **Only APPROVED or APPROVED_WITH_NOTES allows progression to Step 5**

**The builder CANNOT write their own APPROVED verdict.** The review artifact must contain the actual output from a different model. Self-review is only permitted after exhausting ALL reviewers, and the verdict is capped at APPROVED_WITH_NOTES.

### Step 1: PLAN (Primary Builder)

**Goal:** Define what to build, how to build it, and what success looks like.

**Actions:**
1. Read `roadmap.org` for context
2. Define objectives, goals, non-goals
3. Break down into tasks with estimates
4. Identify risks and mitigations
5. Define success criteria (verifiable)
6. Write `Children/{id}/PLAN.md`

**Output:** `Children/{id}/PLAN.md`

**Plan must include:**
- Goal and non-goals
- Public API surface (if applicable)
- Task breakdown with estimates
- Success criteria (checklist)
- Naming (repo, module, product)

---

### Step 2: REVIEW — Plan Review (Cross-Host Reviewer, DIFFERENT model)

**Goal:** Validate the plan before execution begins.

**Actions:**
1. Read `Children/{id}/PLAN.md`
2. Review for completeness, feasibility, consistency
3. Suggest improvements
4. Write `Children/{id}/REVIEW-PLAN.md` with verdict

**Verdicts:**

| Verdict | Meaning | Next Action |
|---------|---------|-------------|
| **APPROVED** | Plan is solid | Proceed to Step 3 |
| **APPROVED_WITH_NOTES** | Minor issues, not blockers | Proceed to Step 3, fix notes during execution |
| **NEEDS_REVISION** | Blockers found | Fix blockers, re-submit for review |

**Output:** `Children/{id}/REVIEW-PLAN.md` (or `REVIEW-PLAN-v{N}.md` for revisions)

---

### Step 3: EXECUTE (Primary Builder)

**Goal:** Implement according to the approved plan.

**Actions:**
1. Implement code
2. Write tests
3. Write documentation (README, API docs)
4. Run `swift build` — must pass
5. Run `swift test` — all must pass
6. Verify success criteria

**Rules:**
- No committing `.build/` artifacts
- Add `.gitignore` before first commit
- Commit incrementally with clear messages
- Never skip tests

**Output:** Working code in `Packages/{repo-name}/`

---

### Step 4: VERIFY — Implementation Review (Cross-Host Reviewer, DIFFERENT model)

**Goal:** Validate the implementation against the approved plan.

**Actions:**
1. **Invoke cross-host reviewer** — Run the CLI command, capture FULL output
2. Read implementation (all source files)
3. Read tests
4. Check: correctness, Swift 6 compliance, API design, test coverage
5. Verify plan items are addressed
6. Write `Children/{id}/REVIEW-IMPL.md` containing the ACTUAL reviewer output

**MANDATORY — Cross-Host Review Capture Protocol**

The builder MUST capture the reviewer's FULL output. Truncated output is useless — the verdict may be lost.

```bash
# ALWAYS redirect to a file. Never rely on terminal buffer.
# The '>' captures stdout+stderr; '2>&1' ensures nothing is lost.

codex review - < /tmp/review_prompt.md > /tmp/reviewer_output.txt 2>&1 &
# Wait for completion, then read the file:
cat /tmp/reviewer_output.txt

# If the file is huge, tail the end where the verdict lives:
tail -100 /tmp/reviewer_output.txt
```

**Why file capture is mandatory:**
- Terminal buffers truncate long output (observed with Codex CLI on macOS)
- Background execution (`&`) prevents the builder session from hanging
- The file can be read back in chunks if it exceeds context limits
- The file serves as the permanent artifact for `REVIEW-IMPL.md`

**If the reviewer's output is truncated even in the file:**
1. Try a shorter prompt (summarize source instead of full code)
2. Try requesting the verdict in the first paragraph of the prompt
3. Try a different reviewer model
4. Document the truncation in `STATUS.md` and proceed with available output

**MANDATORY — Before writing REVIEW-IMPL.md, the builder must:**

```bash
# 1. Try Claude
claude -p "Review <package>..." > /tmp/reviewer_output.txt 2>&1

# 2. If Claude fails or truncates, try Codex
codex review - < /tmp/review_prompt.md > /tmp/reviewer_output.txt 2>&1

# 3. If both fail, document all attempts in STATUS.md, then self-review
```

**REVIEW-IMPL.md must contain:**
- The actual command(s) run
- The actual output from the reviewer (copy-pasted)
- Builder's own checklist (only if cross-host was unavailable)
- Verdict derived from reviewer output, NOT invented

**Verdicts:**

| Verdict | Meaning | Next Action | Who Can Assign |
|---------|---------|-------------|----------------|
| **APPROVED** | Meets all criteria | Proceed to Step 5 | Cross-host reviewer ONLY |
| **APPROVED_WITH_NOTES** | Minor issues | Proceed to Step 5, fix notes | Cross-host reviewer OR self (if all reviewers unavailable) |
| **NEEDS_REVISION** | Blockers found | Fix blockers, re-submit for re-review | Anyone |

**Re-review:** If NEEDS_REVISION, fix blockers and go back to Step 4 (new review round). Each round gets its own `REVIEW-IMPL-v{N}.md`.

**Output:** `Children/{id}/REVIEW-IMPL.md` (or `REVIEW-IMPL-v{N}.md` for re-reviews) — must contain actual reviewer output

**Review Provenance Record:**

After the implementation review completes (regardless of verdict), record:

```markdown
| Aspect | Value |
|--------|-------|
| Reviewer CLI | codex review / claude review / etc. |
| Model | GPT-5.5 / Claude 4 / etc. |
| Verdict | APPROVED / APPROVED_WITH_NOTES / NEEDS_REVISION |
| Rounds | N (1 = first pass, 2+ = revisions needed) |
| Builder | Kimi / Claude / etc. |
```

This record is copied into `REVIEW-PROVENANCE.md` at merge time.

---

### Step 5: DOCUMENT (Primary Builder)

**Goal:** Record what was done and update project state.

**Actions:**
1. Write `Children/{id}/RESULT.md`
2. **Verify REVIEW-IMPL.md exists and contains actual reviewer output**
3. Update `roadmap.org`:
   - Mark child as complete ONLY if cross-host review is APPROVED or APPROVED_WITH_NOTES
   - If self-reviewed, mark as "complete (self-reviewed — cross-host unavailable)"
   - **Include review provenance:** which model reviewed, how many rounds, what was found
   - Update test counts
   - Update progress
4. Update `checklist.legacy`
5. Push final code to GitHub
6. Commit all tracking files

**Output:**
- `Children/{id}/RESULT.md`
- `Children/{id}/REVIEW-PROVENANCE.md` (review lineage record)
- Updated `roadmap.org`
- Updated `checklist.legacy`
- Code pushed to GitHub

**CRITICAL — Post-merge cleanup (Step 5b):**

After a child is merged / pushed, purge stale artifacts to prevent disk bloat and confusion in future sessions.

**iFoundation repo cleanup:**
```bash
rm -rf .build/                    # Swift build artifacts
rm -rf Packages/                  # Local package clones (re-clone fresh next session)
```

**System-wide cleanup:**
```bash
# Reviewer temp files
rm -f /tmp/reviewer_output.txt /tmp/review_*.txt /tmp/review-*.txt
rm -f /tmp/*.bundle /tmp/codex-review*.txt /tmp/claude-review*.txt
rm -rf /tmp/tmp.* /tmp/codex-objects-*

# Xcode DerivedData (stale project builds >2 days old)
find ~/Library/Developer/Xcode/DerivedData -maxdepth 1 -type d -mtime +2 \
  \( -name "Turnip-*" -o -name "UserIdentity-*" -o -name "Rooms-*" \
     -o -name "Unsaved_*" -o -name "swiftanvil-*" \) -exec rm -rf {} +

# iStudio worktree .build directories (if not actively developing)
find ~/Documents/v-i-s-h-a-l/github/iStudio-worktrees -maxdepth 2 -type d -name ".build" -exec rm -rf {} +
```

**What NOT to delete:**
- `Children/{id}/` — permanent planning artifacts
- `RESULT.md`, `REVIEW-PROVENANCE.md` — review lineage
- Git remote repos (already pushed)
- Active DerivedData for projects you're currently working on

**Why this matters:**
- `.build/` directories can grow to 500MB+ per package
- Stale `Packages/` clones confuse the next session about which source is canonical
- Reviewer temp files accumulate in `/tmp/` across sessions
- DerivedData can grow to 100GB+ with stale project folders
- Worktree `.build` dirs bloat inactive branches

**Output:** Clean working directory with only tracked orchestration files.

**CRITICAL — Pre-commit checklist:**
- [ ] `REVIEW-IMPL.md` exists in `Children/{id}/`
- [ ] `REVIEW-IMPL.md` contains actual reviewer output (not just builder's opinion)
- [ ] `REVIEW-PROVENANCE.md` exists with plan + impl review lineage
- [ ] If self-reviewed: `STATUS.md` documents ALL failed reviewer attempts
- [ ] roadmap.org review line is honest about who reviewed what
- [ ] Never claim "Claude reviewed" if Claude was down and you self-reviewed

**REVIEW-PROVENANCE.md Template:**

```markdown
# Review Provenance: Child {id} — {Name}

## Plan Review

| Field | Value |
|-------|-------|
| Reviewer | Codex CLI / Claude CLI / etc. |
| Model | GPT-5.5 / Claude 4 / etc. |
| Verdict | APPROVED / APPROVED_WITH_NOTES / NEEDS_REVISION |
| Rounds | N |
| Key Findings | Bullet list |

## Implementation Review

| Field | Value |
|-------|-------|
| Reviewer | Codex CLI / Claude CLI / etc. |
| Model | GPT-5.5 / Claude 4 / etc. |
| Verdict | APPROVED / APPROVED_WITH_NOTES / NEEDS_REVISION |
| Rounds | N |
| Key Findings | Bullet list |

## Builder

- Primary: Kimi / Claude / etc.
- Session: {session-id}
```

---

## 🚪 Phase Gate Workflow

### When a Phase Completes (All Children Done)

```
Phase N Complete
│
├── 1. Builder writes PHASE-N-SUMMARY.md
│   └── What was built, key decisions, deviations
│
├── 2. Cross-host reviewer reviews entire phase
│   └── Reads all children RESULT.md + roadmap.org
│   └── Writes PHASE-N-REVIEW.md
│   └── Verdict: APPROVED | NEEDS_REVISION
│
├── 3. If APPROVED:
│   └── Builder updates roadmap.org phase status
│   └── Builder tags phase completion in git
│   └── User approval requested for Phase N+1
│
└── 4. If NEEDS_REVISION:
    └── Fix issues in affected children
    └── Re-review
```

### Phase Gate Conditions

| Gate | Condition | Approvers |
|------|-----------|-----------|
| Child complete | Steps 1-5 done, review APPROVED or APPROVED_WITH_NOTES | Cross-host reviewer (or self if all unavailable) |
| Phase N → N+1 | All children have REVIEW-IMPL.md + phase summary reviewed | Cross-host reviewer + User |
| Emergency override | User says "skip review" | User only (documented in ROADMAP) |

**Phase N → N+1 cannot proceed if ANY child is missing REVIEW-IMPL.md.**

---

## 📂 File Structure

```
Children/
├── {id}/
│   ├── PLAN.md              ← Builder writes (Step 1)
│   ├── REVIEW-PLAN.md       ← Reviewer writes (Step 2)
│   ├── REVIEW-PLAN-v2.md    ← Reviewer writes (Step 2, if revision)
│   ├── REVIEW-IMPL.md       ← Reviewer writes (Step 4)
│   ├── REVIEW-IMPL-v2.md    ← Reviewer writes (Step 4, if re-review)
│   ├── RESULT.md            ← Builder writes (Step 5)
│   └── STATUS.md            ← Builder writes (optional, progress)
│
Phase-Summaries/
├── PHASE-1-SUMMARY.md       ← Builder writes
├── PHASE-1-REVIEW.md        ← Reviewer writes
└── ...

Root/
├── workflow.orchestration   ← This file
├── roadmap.org                    ← Living project state
├── checklist.legacy                  ← Task tracking
└── workflow.general                   ← Multi-repo workflow
```

---

## 📋 Review Criteria (Model-Agnostic)

The reviewer evaluates against these criteria regardless of which model they are:

| Criterion | Weight | What to Check |
|-----------|--------|---------------|
| **Correctness** | Critical | Compiles? Tests pass? No logic errors? |
| **Completeness** | High | Meets plan objectives? Nothing missing? |
| **Consistency** | High | Follows Swift idioms? Consistent with other packages? |
| **Test Coverage** | High | Tests exist? Edge cases covered? |
| **Documentation** | Medium | README? API docs? Usage examples? |
| **Swift 6 Compliance** | Medium | Strict concurrency? No warnings? |

---

## ✅ Quality Standards (Model-Agnostic)

### Code Quality
- Swift 6.0+ compatible
- All public APIs documented with `///`
- Test coverage ≥ 80% (where tooling supports)
- No compiler warnings
- All tests pass before merge

### Documentation Quality
- README with installation + quick start
- DocC comments on public APIs
- ADR for architectural decisions (in roadmap.org)

### Review Quality
- Every deliverable reviewed by a DIFFERENT model
- Review must address: correctness, completeness, consistency
- Review feedback must be actionable

---

## 🎭 Agent Role Definitions

### Primary Builder
- Plans implementation (Step 1)
- Writes code (Step 3)
- Writes tests
- Writes documentation
- Updates roadmap.org (Step 5)
- **Can be any model:** Kimi, Claude, GPT-4, Gemini, etc.

### Cross-Host Reviewer
- Reviews plans (Step 2)
- Reviews implementations (Step 4)
- Reviews phase summaries
- Writes REVIEW-*.md files
- Approves phase gates
- **MUST be a different model from the builder**
- **Can be any model:** Kimi, Claude, GPT-4, Gemini, etc.

### User
- Vision and direction
- Phase gate approval
- Model selection (or delegates to random)
- Final decision authority
- Emergency override

---

## 🚨 Escalation

### If Agents Disagree
1. Both models document positions in `Children/{id}/REVIEW-*.md`
2. User decides
3. Decision is final

### If Stuck
1. Model documents blocker in `Children/{id}/STATUS.md`
2. User provides guidance
3. Resume work

### If Reviewer is Unavailable
1. Try ALL available cross-host reviewers in order: Claude CLI → Codex CLI → OpenAI CLI → any other authenticated CLI
2. Document each attempt with error output in `Children/{id}/STATUS.md`
3. Only after ALL reviewers fail, proceed with self-review
4. Self-review MUST use the same checklist as cross-host review (see Review Criteria below)
5. Self-review verdict is ALWAYS "APPROVED_WITH_NOTES" or "NEEDS_REVISION" — never "APPROVED"
6. Document in roadmap.org as "self-reviewed — all cross-host reviewers unavailable"
7. **NEVER mark a child as fully APPROVED without cross-host review** — the phase gate remains conditional

---

## 🔧 Framework Self-Improvement

This framework has **autonomy to update itself**. The builder agent may modify this file when executing a task reveals a genuine improvement to the workflow.

### When to Update

Update this framework when you encounter:
- A recurring friction point that slows every child (e.g., "tests fail for the same reason every time")
- A gap in the review capture protocol that causes lost output
- A missing checklist item that leads to repeated mistakes
- A clearer way to express an existing rule

### When NOT to Update

Do NOT update for:
- One-off issues specific to a single child
- Stylistic preferences that don't affect correctness
- Changes that contradict the core principle (different-model review)

### How to Update

1. **Identify the improvement during execution** — note it while working, don't stop the task
2. **Apply the fix to the current child** — demonstrate it works
3. **Update this file** — add or modify the relevant section
4. **Document in version history** — include what changed and why
5. **No separate review required** — the improvement was proven during execution

### Examples of Past Self-Updates

| Version | What Changed | Why |
|---------|-------------|-----|
| 3.1 | Added honest-review-enforcement rules | Children were being marked APPROVED without cross-host review |
| 3.2 | Added REVIEW-PROVENANCE.md | Review lineage was lost after merge |
| 3.3 | Mandated file redirection for review capture | Reviewer output was truncated in terminal buffers |

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-06-02 | Initial framework (Kimi-specific) |
| 2.0 | 2026-06-02 | Agent-agnostic rewrite, model rotation rules |
| 3.0 | 2026-06-03 | Formalized 5-step per-child workflow, phase gates, file structure |
| 3.1 | 2026-06-03 | Hardened reviewer-unavailable procedure, banned false-positive approvals, enforced honest review provenance |
| 3.2 | 2026-06-03 | Added REVIEW-PROVENANCE.md requirement, post-merge review lineage tracking, provenance table format |
| 3.3 | 2026-06-03 | Hardened cross-host review capture protocol — file redirection mandatory, truncation handling, background execution |
| 3.4 | 2026-06-04 | Added Framework Self-Improvement section — builder has autonomy to update workflow when execution reveals genuine improvements |
| 3.5 | 2026-06-04 | Added Post-merge cleanup step — purge stale artifacts, temp files, derived data, and local package clones after merge |

---

*Framework is model-agnostic. Any capable LLM can be builder or reviewer. The only rule: they must be different.*

**Stale branch cleanup:**

```bash
# List all branches (local and remote)
git branch -a

# Delete local branches that were merged
git branch --merged main | grep -v "^\* main$" | xargs -r git branch -d

# Delete remote branches that were merged (use with caution)
git fetch --prune origin

# Force-delete unmerged branches (only if abandoned)
git branch -D <branch-name>
```

**Rule:** Only `main` should remain after merge. Feature branches, review branches, and temp branches must be deleted once their code is in `main`.
