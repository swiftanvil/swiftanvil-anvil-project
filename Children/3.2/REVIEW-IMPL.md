# Cross-Host Review: Child 3.2 — AnvilTemplate

**Reviewer:** Codex CLI (GPT-5.5) via `codex review`
**Date:** 2026-06-03
**Review Type:** Implementation review (source + tests)

## Review Prompt

Full source code of all 8 source files + test suite (28 tests) + public API specification + template syntax documentation.

## Reviewer Findings

### [P0] Pass the render context through Template.render
**File:** `Sources/AnvilTemplate/Core/Template.swift:17`
**Finding:** `Template.render(context:mode:)` calls `TemplateRenderer.render(nodes:mode:)` omitting the `context:` argument.
**Resolution:** FALSE POSITIVE. The actual source file correctly passes `context: context` at line 21. The review prompt contained an outdated copy of the file from an intermediate editing state. `swift build` passes and all tests execute correctly.

### [P2] Allow documented comments inside block bodies
**File:** `Sources/AnvilTemplate/Parser/TemplateParser.swift:146-150`
**Finding:** Comments inside `{{#if}}` or `{{#each}}` blocks throw `Comments inside blocks not supported`.
**Resolution:** BY DESIGN. The PLAN.md explicitly documents "Comment in block" as one of the 10 parser error cases. The rationale: keeping block bodies simple avoids ambiguity about whether comments should be rendered as empty strings or truly skipped (affecting whitespace). This restriction may be relaxed in a future version if needed.

### [P2] Match closing tags using trimmed tag content
**File:** `Sources/AnvilTemplate/Parser/TemplateParser.swift:153-154`
**Finding:** Closing tags with whitespace (e.g. `{{ /if }}` or `{{/if }}`) fail because the parser compares the raw substring against the exact `endTag` string.
**Resolution:** FIXED. Changed the end-tag check from `fullTag == endTag` to comparing trimmed `tagContent` against the inner content of `endTag`. Added 2 tests verifying whitespace-tolerant closing tags for both `{{/if}}` and `{{/each}}`. All 30 tests pass.

## Verdict

**APPROVED_WITH_NOTES**

- 1 false positive (outdated source in review prompt)
- 1 by-design behavior (comments in blocks rejected)
- 1 real bug fixed (whitespace-tolerant closing tags)

## Post-Review State

- Tests: 30/30 passing
- Build: clean (0 errors, 1 warning: async/await in non-async test — cosmetic)
- Bug fixes applied: 1
