# Improvement Framework — SwiftAnvil

> Proactive, continuous improvement. No package is ever "done." Every package has a next version.

---

## Core Principle

**Passive roadmaps are dead roadmaps.** A roadmap that sits in a file and waits for a human to read it is useless. The framework must **force** improvement by:

1. **Scoring** every package against objective quality criteria
2. **Triggering** improvement work when scores drop below thresholds
3. **Scheduling** regular improvement reviews (not just when someone remembers)
4. **Escalating** stagnation to the user when AI agents can't resolve it

---

## Package Maturity Score (PMS)

Every package gets a score from 0-100. The score is calculated automatically from verifiable metrics.

| Category | Weight | Metrics | How Measured |
|----------|--------|---------|--------------|
| **Correctness** | 25% | Tests pass, no compiler warnings, no crashes | `swift test`, `swift build` |
| **Coverage** | 20% | Test coverage %, edge cases covered | Swift Testing coverage (when available) + manual audit |
| **Documentation** | 15% | README completeness, API docs, usage examples | Checklist audit |
| **API Stability** | 15% | Breaking changes since last version, deprecation policy | Semver audit |
| **Performance** | 10% | Benchmarks exist, performance regression tests | BenchmarkKit integration |
| **Ecosystem** | 10% | CI/CD, SPI listing, community issues/PRs | GitHub API + file check |
| **Security** | 5% | No hardcoded secrets, dependency audit | `grep -r`, dependabot check |

### Score Thresholds

| Score | Grade | Action Required |
|-------|-------|-----------------|
| 90-100 | A+ | None — exemplary |
| 80-89 | A | Minor improvements scheduled |
| 70-79 | B | Improvement sprint required within 2 weeks |
| 60-69 | C | **BLOCKER** — cannot release new features until score improves |
| <60 | F | **EMERGENCY** — package needs rewrite or deprecation |

### Score Persistence

Each package's score lives in its repo at `.improvement/score.json`:

```json
{
  "version": "1.0.0",
  "score": 78,
  "grade": "B",
  "breakdown": {
    "correctness": 25,
    "coverage": 12,
    "documentation": 10,
    "api_stability": 15,
    "performance": 8,
    "ecosystem": 5,
    "security": 3
  },
  "last_calculated": "2026-06-04T02:30:00Z",
  "next_review": "2026-06-18T02:30:00Z",
  "improvement_items": [
    { "id": "cov-1", "category": "coverage", "description": "Add tests for error paths", "impact": 5, "effort": "small" },
    { "id": "doc-1", "category": "documentation", "description": "Add usage examples to README", "impact": 3, "effort": "small" }
  ]
}
```

---

## Improvement Triggers

The system triggers improvement work automatically. No human or AI should need to "remember" to check.

### Trigger 1: Score Drop (Automatic)

When `swift test` or `swift build` is run, the system checks:
- Did tests fail? → Correctness score drops
- Did new warnings appear? → Correctness score drops
- Is coverage lower than last run? → Coverage score drops

If any category drops by >5 points, an improvement item is auto-created.

### Trigger 2: Time-Based Review (Scheduled)

Every package gets a scheduled improvement review:

| Grade | Review Frequency |
|-------|-----------------|
| A+ | Monthly |
| A | Bi-weekly |
| B | Weekly |
| C | Every 3 days |
| F | Daily until resolved |

The review is a cron job or scheduled task that:
1. Runs the full test suite
2. Calculates the PMS
3. Compares to previous score
4. If score dropped or <80, creates an improvement issue

### Trigger 3: Cross-Host Review Finding (Event-Driven)

When a cross-host reviewer finds an issue:
- P1 blocker → Auto-create improvement item, score drops 10 points
- P2 issue → Auto-create improvement item, score drops 5 points
- P3 suggestion → Add to backlog, no score impact

### Trigger 4: Dependency Update (Event-Driven)

When a dependency releases a new version:
- Check for breaking changes
- If breaking, create improvement item to migrate
- If security fix, create urgent improvement item

### Trigger 5: User Request (Manual)

User says "improve X" → Create improvement item, schedule sprint.

---

## Improvement Sprint Workflow

When a trigger fires, the system enters an **Improvement Sprint**.

```
Trigger Fires
│
├── 1. Create Improvement Item in .improvement/backlog.md
│   └── ID, category, description, impact, effort, deadline
│
├── 2. If score < 80 or P1 found:
│   └── BLOCK new feature work on this package
│
├── 3. Schedule sprint (next available slot)
│   └── Bumps other non-urgent work
│
├── 4. Execute (same 5-step workflow as new children)
│   └── PLAN → REVIEW → EXECUTE → VERIFY → DOCUMENT
│
├── 5. Recalculate PMS
│   └── If score improved → unblock features
│   └── If score stagnant → escalate to user
│
└── 6. Archive item to .improvement/completed.md
```

---

## Per-Repo Improvement Roadmap

Every package repo contains `ROADMAP.md` at its root. This is **not** the org roadmap — it's the package's own improvement trajectory.

### Template: `ROADMAP.md` (per package)

```markdown
# AnvilTemplate Roadmap

> Current version: 1.0.0 | PMS: 78 (B) | Next review: 2026-06-18

## Now (v1.0.x)

- [ ] Add `.dictionary` to `TemplateValue` (blocked: needs design review)
- [ ] Support nested loops `{{#each outer}}{{#each inner}}{{.}}{{/each}}{{/each}}`
- [ ] Add `{{#unless}}` directive

## Next (v1.1.0)

- [ ] Template file caching (parse once, render many)
- [ ] Partial templates `{{> header}}`
- [ ] Strict mode by default option

## Later (v2.0.0)

- [ ] Async template rendering (for I/O-bound partials)
- [ ] Template compilation to Swift code (zero-parse overhead)
- [ ] IDE support (syntax highlighting, autocomplete)

## Improvement History

| Date | Version | Change | PMS Delta |
|------|---------|--------|-----------|
| 2026-06-03 | 1.0.0 | Initial release | 78 → 78 |
```

### How the AI Knows What to Work On

The AI reads the package's `ROADMAP.md` and `.improvement/score.json` at session start:

1. **If score < 80** → Improvement sprint takes priority over new features
2. **If any item is marked "blocked"** → Check if blocker is resolved
3. **If version gap exists** (e.g., v1.0.0 but v1.1.0 items are ready) → Suggest upgrade
4. **If no items exist** → Run PMS calculation to generate some

---

## Org-Level Improvement Dashboard

The iFoundation repo tracks all packages in one view:

```markdown
# SwiftAnvil Improvement Dashboard

| Package | Version | PMS | Grade | Status | Next Action |
|---------|---------|-----|-------|--------|-------------|
| AnvilTemplate | 1.0.0 | 78 | B | 🟡 Improve | Add `.dictionary` support |
| AnvilProject | 1.0.0 | 82 | A | 🟢 Healthy | Minor doc improvements |
| AnvilDocs | 1.0.0 | 75 | B | 🔴 Sprint | Fix P2 issues from review |
| ... | ... | ... | ... | ... | ... |

**Sprints This Week:**
- AnvilDocs: Landing page template support (v1.1.0)
- AnvilTemplate: `.dictionary` + nested loops (v1.1.0)

**Blocked:**
- AnvilNetwork: Waiting for Swift 6.1 `URLSession` changes
```

This lives in `iFoundation/IMPROVEMENT_DASHBOARD.md` and is updated after every child completion.

---

## AI Agent Integration

### How the Builder Knows What to Improve

At session start, the builder reads:
1. `iFoundation/IMPROVEMENT_DASHBOARD.md` — what's urgent across all packages
2. `Packages/swiftanvil/<repo>/ROADMAP.md` — what's next for this package
3. `Packages/swiftanvil/<repo>/.improvement/score.json` — current health

**Decision tree:**
```
Is any package score < 70?
  Yes → Improvement sprint on that package (blocks new features)
  No → Continue with planned child

Is planned child's dependencies score < 80?
  Yes → Improve dependency first
  No → Proceed with planned child
```

### How the Reviewer Knows What to Check

The reviewer reads the package's `ROADMAP.md` before reviewing:
- Are "Now" items addressed?
- Did the implementation move the package toward "Next"?
- Did the PMS improve or regress?

### Proactive Suggestions

The AI can suggest improvements without user prompting:

```
[Proactive] AnvilTemplate v1.0.0 has been stable for 2 weeks.
PMS: 78 (B). Suggested sprint:
1. Add `.dictionary` to TemplateValue (+5 coverage, +3 ecosystem)
2. Add nested loop support (+5 correctness)
Estimated new PMS: 88 (A)

Schedule sprint? [y/n]
```

---

## Anti-Stagnation Rules

1. **No package sits at B for more than 2 sprints** — must reach A or user is notified
2. **No "Later" item stays in "Later" for more than 3 months** — either move to "Next" or delete
3. **Every sprint must improve at least one PMS category** — no cosmetic-only sprints
4. **If score drops, feature work stops** — quality is not negotiable

---

## Implementation Plan

### Phase 1: Scoring (Immediate)
- [ ] Add `.improvement/` directory to each repo
- [ ] Create `score.json` manually for existing packages
- [ ] Add PMS calculation script to iFoundation

### Phase 2: Automation (After Child 3.5)
- [ ] GitHub Actions workflow to calculate PMS on every PR
- [ ] Cron job for scheduled reviews
- [ ] Auto-create issues when score drops

### Phase 3: Proactive AI (After Phase 4)
- [ ] AI reads dashboard at session start
- [ ] AI suggests sprints based on stagnation rules
- [ ] AI auto-schedules improvement work

---

*This framework ensures SwiftAnvil packages don't just get built — they get better.*
