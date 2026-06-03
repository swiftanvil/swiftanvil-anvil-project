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
- [ ] 00-META.md
- [ ] 01-IDENTITY.md
- [ ] 02-PLATFORM_POLICY.md
- [ ] 03-ORCHESTRATION.md
- [ ] 04-IMPROVEMENT.md
- [ ] 07-PACKAGES.md
- [ ] 08-NAMING.md

## Step 2: Check Health (1 min)

- [ ] Any package score < 80? → Improvement sprint first
- [ ] Any platform policy violations? → Upgrade sprint first
- [ ] Any blocked items? → Check if unblocked
- [ ] Any stale branches? → Clean up

## Step 3: Plan Work (2 min)

- [ ] Read ROADMAP.md for planned child
- [ ] Check if dependencies need updating
- [ ] Verify platform requirements match policy (iOS 18+, macOS 15+)

## Step 4: Execute

Proceed with planned work, following ORCHESTRATION_FRAMEWORK.md.

## Step 5: Update Memory (1 min)

- [ ] Update 07-PACKAGES.md if scores changed
- [ ] Update 08-NAMING.md if names changed
- [ ] Update 06-API_MODERNIZATION.md if old APIs found
- [ ] Commit all memory changes

---

**Total startup time: ~7 minutes. Prevents hours of rework.**
