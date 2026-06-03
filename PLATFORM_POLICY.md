# Platform Policy — SwiftAnvil

> **Latest OS + One Previous.** No legacy. No compatibility shims. No `#available` clutter.

---

## Core Principle

**SwiftAnvil targets developers building modern apps.** We do not support old OS versions that force us to:
- Write `#available` checks
- Maintain deprecated API wrappers
- Test on obsolete simulators
- Document workarounds for bugs Apple fixed years ago

**The policy is absolute.** No exceptions without user override.

---

## Current Support Matrix

| Platform | Minimum | Maximum | Notes |
|----------|---------|---------|-------|
| **iOS** | 18.0 | 26.0 (latest) | iOS 18 is the floor. iPadOS same version. |
| **macOS** | 15.0 | 26.0 (latest) | Sequoia minimum. |
| **tvOS** | 18.0 | 26.0 (latest) | Same cycle as iOS. |
| **watchOS** | 11.0 | 26.0 (latest) | Aligned with iOS 18. |
| **visionOS** | 2.0 | 26.0 (latest) | visionOS 2+ only. |

### What "Minimum" Means

- All code **must** compile with `DeploymentTarget >= minimum`
- All APIs used **must** be available on `minimum` without `#available`
- All tests **must** pass on simulators running `minimum`
- No `#if available`, `@available`, or `if #available` allowed

### What "Maximum" Means

- We adopt new APIs from the latest OS within **2 weeks** of GM release
- New features should use latest APIs where beneficial
- We do not wait for adoption curves — our users are early adopters

---

## Migration Rule

When a new OS releases (e.g., iOS 27):

```
Month 0-1:  Support iOS 18 + iOS 26 + iOS 27 (3 versions)
Month 2-3:  Drop iOS 18, support iOS 26 + iOS 27 (2 versions)
Month 4+:   Support iOS 26 + iOS 27 (latest + previous)
```

**The "One Previous" rule:** We always support the latest OS plus exactly one previous major version. Never more.

### Migration Checklist

When dropping an OS version:

- [ ] Update `Package.swift` platform requirements
- [ ] Update all `#if available` → remove, since minimum is now higher
- [ ] Update README.md platform badges
- [ ] Update CI matrix (remove old simulators)
- [ ] Search for deprecated API usage → modernize
- [ ] Search for workaround comments → remove if Apple fixed
- [ ] Update `PLATFORM_POLICY.md` current matrix
- [ ] Tag a breaking release (semver major or minor)

---

## API Modernization

### What to Modernize

When dropping an OS version, search for and update:

| Pattern | Old (iOS 17) | New (iOS 18+) |
|---------|-------------|---------------|
| `UIApplication.openSettingsURLString` | Still works | No change needed |
| `NotificationCenter` | `addObserver` | `notifications` async sequence |
| `URLSession` | Completion handlers | `bytes(for:)` async |
| `FileManager` | Synchronous | `.withDirectory` modern APIs |
| `SwiftUI @State` | Simple | `@Observable` macro |
| `Combine` | `Publisher` chains | `AsyncSequence` + `async` |
| `XCTest` | `XCTAssert` | Swift Testing `#expect` |

### How to Track

Every package has `API_MODERNIZATION.md`:

```markdown
# API Modernization Log — AnvilTemplate

## iOS 18+ APIs We Should Adopt

| API | Current Usage | Modern Replacement | Status |
|-----|--------------|-------------------|--------|
| `String.components(separatedBy:)` | TemplateParser.swift:45 | `String.split(separator:)` | ⏳ Pending |
| `NSRegularExpression` | TemplateParser.swift:89 | `RegexBuilder` | ⏳ Pending |

## Completed

| Date | API | File | PR |
|------|-----|------|-----|
| 2026-06-04 | `JSONSerialization` → `JSONDecoder` | TargetDiscovery.swift | #12 |
```

---

## Enforcement Mechanisms

### 1. Build-Time Enforcement

Every `Package.swift` must declare platforms explicitly:

```swift
platforms: [
    .iOS(.v18),
    .macOS(.v15),
    .tvOS(.v18),
    .watchOS(.v11),
    .visionOS(.v2)
]
```

**No `.v13`, `.v14`, `.v16`, `.v17` allowed.** The build fails if minimums are wrong.

### 2. Lint Rule (Future)

```bash
# Fails CI if any of these patterns are found
swiftanvil lint --platform-policy
```

Checks for:
- `#available` or `@available` in source
- Platform versions below policy minimum
- Deprecated API usage that has modern replacements
- `#if os(iOS)` without matching minimum version check

### 3. Review Checklist

Cross-host reviewers must verify:
- [ ] No `#available` / `@available` in new code
- [ ] Platforms in `Package.swift` match policy
- [ ] No deprecated API usage without `API_MODERNIZATION.md` entry
- [ ] README badges show correct minimum versions

### 4. AI Memory

The AI reads `PLATFORM_POLICY.md` at every session start. It is part of the **host-agnostic memory system** (see `MEMORY_SYSTEM.md`).

**If AI generates code with old API:**
- Self-correct during implementation
- Flag in review if missed
- Add to `API_MODERNIZATION.md` if discovered later

---

## Legacy Cleanup Sprints

When the policy changes (e.g., drop iOS 18, add iOS 27):

```
Week 1: Update Package.swift platforms, CI matrix
Week 2: Remove all #available / @available
Week 3: Modernize APIs (see API_MODERNIZATION.md)
Week 4: Update docs, release notes, tags
```

This is a **scheduled improvement sprint**, not ad-hoc work.

---

## Why This Matters

| Without Policy | With Policy |
|---------------|-------------|
| `#available` everywhere | Clean, linear code |
| Test matrix of 5+ OS versions | Test on 2 versions |
| Documentation for workarounds | Documentation for features |
| Fear of using new APIs | First-class new API adoption |
| Technical debt accumulates | Debt is systematically removed |
| AI generates compatibility code | AI generates modern code |

---

## Version History

| Date | Change |
|------|--------|
| 2026-06-04 | Initial policy: iOS 18+, macOS 15+, tvOS 18+, watchOS 11+, visionOS 2+ |
