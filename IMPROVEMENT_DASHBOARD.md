# SwiftAnvil Improvement Dashboard

> Auto-generated from `package.improvement-score`. Updated after every child completion.

*Last updated: 2026-06-04*

---

## Package Health Overview

| Package | Version | PMS | Grade | Status | Next Review | Next Action |
|---------|---------|-----|-------|--------|-------------|-------------|
| AnvilTemplate | 1.0.0 | 78 | B | 🟡 Improve | 2026-06-18 | Add `.dictionary` to `TemplateValue` |
| AnvilProject | 1.0.0 | 82 | A | 🟢 Healthy | 2026-06-18 | Minor doc improvements |
| AnvilDocs | 1.0.0 | 75 | B | 🔴 Sprint | 2026-06-11 | Use AnvilTemplate for landing page |

**Legend:** 🟢 Healthy (A) | 🟡 Improve (B) | 🔴 Sprint (C/F) | ⚪ Unknown

---

## Sprints This Week

| Package | Item | Impact | Effort | Target Version |
|---------|------|--------|--------|----------------|
| AnvilDocs | DOC-001: Template-based landing page | 5 | medium | 1.1.0 |
| AnvilDocs | DOC-003: GitHub Actions workflow | 3 | small | 1.0.1 |

**Blocked:**
- DOC-001 (AnvilDocs) → blocked by TPL-002 (AnvilTemplate `.dictionary`)

---

## Improvement Queue (Prioritized)

### High Impact (≥5)

| ID | Package | Description | Impact | Effort | Blocked By |
|----|---------|-------------|--------|--------|------------|
| TPL-002 | AnvilTemplate | Add `.dictionary` to `TemplateValue` | 8 | medium | — |
| DOC-002 | AnvilDocs | Integration tests with real docc | 5 | large | — |
| TPL-003 | AnvilTemplate | Template parse caching | 5 | small | — |
| DOC-001 | AnvilDocs | Template-based landing page | 5 | medium | TPL-002 |

### Medium Impact (3-4)

| ID | Package | Description | Impact | Effort |
|----|---------|-------------|--------|--------|
| TPL-001 | AnvilTemplate | Nested loop error path tests | 3 | small |
| PRJ-001 | AnvilProject | Advanced README examples | 3 | small |
| DOC-003 | AnvilDocs | GitHub Actions workflow | 3 | small |

---

## Anti-Stagnation Alerts

| Rule | Status |
|------|--------|
| No package at B for >2 sprints | ✅ All B packages on first sprint |
| No "Later" item >3 months old | ✅ All packages <1 month old |
| Every sprint improves ≥1 category | ⏳ Next sprint: TPL-002 (correctness +8) |

---

## How to Use This Dashboard

**For AI Builders:**
1. Read this at session start
2. If any package is 🔴, improvement sprint takes priority
3. If any item is "blocked", check if blocker is resolved
4. Pick highest-impact, lowest-effort item when choosing work

**For Reviewers:**
1. Check if implementation improves PMS
2. Verify "Now" items from package ROADMAP are addressed
3. Flag if score would regress

**For Users:**
1. See what's being improved and why
2. Override priorities if business needs differ
3. Get notified when packages stagnate

---

*This dashboard is proactive. It tells you what to improve before you forget.*
