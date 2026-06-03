---
priority: CRITICAL
type: CHECKLIST
audience: BUILDER
last_updated: 2026-06-04
---

# Session Start Checklist

Every session begins here. Do not skip steps.

## Step 1: Load Memory (2 min)

Read in order:
- [ ] memory.meta
- [ ] memory.identity
- [ ] policy.platform
- [ ] workflow.orchestration
- [ ] improvement.framework
- [ ] packages.registry
- [ ] naming.registry

## Step 2: Check Health (1 min)

- [ ] Any package score < 80? → Improvement sprint first
- [ ] Any platform policy violations? → Upgrade sprint first
- [ ] Any blocked items? → Check if unblocked
- [ ] Any stale branches? → Clean up

## Step 3: Plan Work (2 min)

- [ ] Read roadmap.org for planned child
- [ ] Check if dependencies need updating
- [ ] Verify platform requirements match policy (iOS 18+, macOS 15+)

## Step 4: Execute

Proceed with planned work, following workflow.orchestration.

## Step 5: Update Memory (1 min)

- [ ] Update packages.registry if scores changed
- [ ] Update naming.registry if names changed
- [ ] Update modernization.api if old APIs found
- [ ] Commit all memory changes

---

**Total startup time: ~7 minutes. Prevents hours of rework.**
