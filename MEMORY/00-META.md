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
