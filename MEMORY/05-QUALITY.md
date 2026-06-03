---
priority: HIGH
type: POLICY
audience: BOTH
last_updated: 2026-06-04
---

# Quality Standards

## Code Quality

- Swift 6.0+ compatible with strict concurrency
- All public APIs documented with `///`
- Test coverage ≥ 80% (where tooling supports)
- No compiler warnings
- All tests pass before merge

## API Design

- Use `async` / `await` for async operations
- Use `Result` or `throws` for error handling, not tuples
- Use `Sendable` conformance for all public types
- Prefer structs over classes
- Prefer `let` over `var`

## Documentation Quality

- README with installation + quick start
- DocC comments on every public API
- Usage examples in README
- ADR for architectural decisions

## Review Quality

- Every deliverable reviewed by a DIFFERENT model
- Review must address: correctness, completeness, consistency
- Review feedback must be actionable
