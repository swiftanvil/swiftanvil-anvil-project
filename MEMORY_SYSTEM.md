# Host-Agnostic Memory System — SwiftAnvil

> Structured, loadable instructions that any LLM can read and follow. No inference drift. No forgotten policies.

---

## Core Principle

**LLMs have no memory between sessions.** The only memory is the files we write. If a policy is not in a file that gets read at session start, it does not exist for the AI.

This system ensures:
- Every session starts with the same context
- Policies are enforced, not suggested
- No host-specific knowledge is required
- Any capable LLM can be the builder or reviewer

---

## Memory Structure

The memory is a **hierarchy** — each level overrides the one above for its scope.

```
MEMORY/
├── 00-META.md              ← How to use this memory system
├── 01-IDENTITY.md          ← Who we are, what we build
├── 02-PLATFORM_POLICY.md   ← OS support, API modernization (PLATFORM_POLICY.md)
├── 03-ORCHESTRATION.md     ← How we work (ORCHESTRATION_FRAMEWORK.md)
├── 04-IMPROVEMENT.md       ← How we improve (IMPROVEMENT_FRAMEWORK.md)
├── 05-QUALITY.md           ← Code quality standards
├── 06-API_MODERNIZATION.md ← What to modernize (API_MODERNIZATION.md)
├── 07-PACKAGES.md          ← Package registry with current scores
└── 99-SESSION_START.md     ← Checklist for every new session
```

### Loading Order

At session start, the AI **must** read files in this order:

1. `00-META.md` — understand the system
2. `01-IDENTITY.md` — understand the project
3. `02-PLATFORM_POLICY.md` — know what OS/APIs to target
4. `03-ORCHESTRATION.md` — know the workflow
5. `04-IMPROVEMENT.md` — know how to improve
6. `07-PACKAGES.md` — know current package health
7. `99-SESSION_START.md` — execute the startup checklist

**Total read time:** ~2 minutes. **Total context used:** ~500 lines.

---

## File Format Rules

Every memory file follows strict formatting so LLMs parse it reliably:

### 1. Frontmatter

```markdown
---
priority: CRITICAL | HIGH | MEDIUM | LOW
type: POLICY | WORKFLOW | REFERENCE | CHECKLIST
audience: BUILDER | REVIEWER | BOTH
last_updated: 2026-06-04
---
```

### 2. One Idea Per Section

```markdown
## Section Title

> One-sentence summary of the rule.

Details here. Keep paragraphs short.

### Enforcement
How this is enforced. Specific commands, checks, or consequences.

### Example
```swift
// Good: follows the rule
let modern = newAPI()

// Bad: violates the rule
let legacy = oldAPI() // ❌ Deprecated in iOS 18
```
```

### 3. Tables for Reference Data

```markdown
| Platform | Minimum | Notes |
|----------|---------|-------|
| iOS | 18.0 | No iOS 17 support |
```

### 4. Checklists for Actions

```markdown
- [ ] Read PLATFORM_POLICY.md
- [ ] Verify Package.swift platforms
```

### 5. No Ambiguity

- Use **must** for requirements
- Use **should** for strong recommendations
- Use **may** for optional things
- Never use "consider", "think about", "maybe"

---

## 00-META.md

```markdown
---
priority: CRITICAL
type: REFERENCE
audience: BOTH
last_updated: 2026-06-04
---

# How to Use This Memory System

## For AI Builders

1. At session start, read files 00-07 in order
2. Before writing code, read 02-PLATFORM_POLICY.md
3. Before reviewing, read 03-ORCHESTRATION.md
4. After completing work, update 07-PACKAGES.md

## For AI Reviewers

1. Read 02-PLATFORM_POLICY.md — check for violations
2. Read 05-QUALITY.md — check standards
3. Read 06-API_MODERNIZATION.md — check for old APIs

## For Humans

1. Edit any file to update policy
2. The AI will read the updated version next session
3. No restart or notification needed

## File Update Rules

- Update `last_updated` when changing a file
- Add version history at bottom
- Never delete sections — mark deprecated instead
```

---

## 01-IDENTITY.md

```markdown
---
priority: CRITICAL
type: REFERENCE
audience: BOTH
last_updated: 2026-06-04
---

# SwiftAnvil Identity

## What We Build

SwiftAnvil is a suite of Swift packages for building modern Apple platform apps. We prioritize:

1. **Latest OS first** — iOS 18+, macOS 15+, etc.
2. **Swift 6 strict concurrency** — no exceptions
3. **Zero dependencies** where possible — pure Swift + Foundation
4. **Test-driven** — every public API has tests
5. **DocC-documented** — every public symbol

## What We Don't Do

- Support old OS versions (see PLATFORM_POLICY.md)
- Use deprecated APIs (see API_MODERNIZATION.md)
- Add dependencies for trivial functionality
- Skip cross-host review
- Merge without tests passing

## Org Structure

- GitHub: github.com/swiftanvil
- Naming: swiftanvil-anvil-<name>
- License: MIT
```

---

## 99-SESSION_START.md

```markdown
---
priority: CRITICAL
type: CHECKLIST
audience: BUILDER
last_updated: 2026-06-04
---

# Session Start Checklist

Every session begins here. Do not skip steps.

## Step 1: Load Memory (2 min)

- [ ] Read MEMORY/00-META.md
- [ ] Read MEMORY/01-IDENTITY.md
- [ ] Read MEMORY/02-PLATFORM_POLICY.md
- [ ] Read MEMORY/03-ORCHESTRATION.md
- [ ] Read MEMORY/04-IMPROVEMENT.md
- [ ] Read MEMORY/07-PACKAGES.md

## Step 2: Check Health (1 min)

- [ ] Any package score < 80? → Improvement sprint first
- [ ] Any blocked items? → Check if unblocked
- [ ] Any stale branches? → Clean up

## Step 3: Plan Work (2 min)

- [ ] Read ROADMAP.md for planned child
- [ ] Check if dependencies need updating
- [ ] Verify platform requirements match policy

## Step 4: Execute

Proceed with planned work, following ORCHESTRATION_FRAMEWORK.md.

## Step 5: Update Memory (1 min)

- [ ] Update 07-PACKAGES.md if scores changed
- [ ] Update API_MODERNIZATION.md if old APIs found
- [ ] Commit all memory changes
```

---

## Physical Layout

In the repo, the memory lives at:

```
iFoundation/
├── MEMORY/
│   ├── 00-META.md
│   ├── 01-IDENTITY.md
│   ├── 02-PLATFORM_POLICY.md      ← symlink to ../PLATFORM_POLICY.md
│   ├── 03-ORCHESTRATION.md        ← symlink to ../ORCHESTRATION_FRAMEWORK.md
│   ├── 04-IMPROVEMENT.md          ← symlink to ../IMPROVEMENT_FRAMEWORK.md
│   ├── 05-QUALITY.md              ← TBD
│   ├── 06-API_MODERNIZATION.md    ← symlink to ../API_MODERNIZATION.md
│   ├── 07-PACKAGES.md             ← generated from .improvement/score.json
│   └── 99-SESSION_START.md
```

Symlinks ensure single source of truth. The MEMORY directory is the **loadable interface**.

---

## Why This Prevents Drift

| Without Memory System | With Memory System |
|----------------------|-------------------|
| AI forgets OS policy | AI reads PLATFORM_POLICY.md every session |
| AI uses deprecated APIs | AI checks API_MODERNIZATION.md before coding |
| AI skips review | AI follows ORCHESTRATION.md checklist |
| AI builds wrong thing | AI reads IDENTITY.md and PACKAGE scores first |
| Different AIs behave differently | All AIs load the same memory |

---

*The memory is the project. The AI is just the executor.*
