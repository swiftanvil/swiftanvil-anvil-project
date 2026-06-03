# Platform Upgrade Plan — iOS 18+ / macOS 15+

> All packages must upgrade from iOS 16 → iOS 18, macOS 13 → macOS 15.
> This is a scheduled improvement sprint, not optional.

---

## Why Now

The PLATFORM_POLICY.md (02-PLATFORM_POLICY.md) mandates:
- **iOS 18+ minimum** (not 16, not 17)
- **macOS 15+ minimum** (not 13, not 14)
- No `#available`, no `@available`, no legacy shims

All existing packages were built before this policy. They must be upgraded.

---

## Upgrade Checklist (Per Package)

### 1. Package.swift

```swift
// BEFORE (non-compliant)
platforms: [.iOS(.v16), .macOS(.v13)]

// AFTER (compliant)
platforms: [.iOS(.v18), .macOS(.v15), .tvOS(.v18), .watchOS(.v11), .visionOS(.v2)]
```

### 2. Source Code

- [ ] Search for `#available` → remove (no longer needed)
- [ ] Search for `@available` → remove
- [ ] Search for `#if os(iOS)` with version checks → simplify
- [ ] Search for `if #available` → remove blocks, keep modern path only

### 3. API Modernization

- [ ] `JSONSerialization` → `JSONDecoder` / `Codable`
- [ ] `NSRegularExpression` → `RegexBuilder`
- [ ] `ObservableObject` → `@Observable`
- [ ] `DispatchQueue` → `Task` / `async`
- [ ] Completion handlers → `async` methods

### 4. Tests

- [ ] Update test target platform requirements
- [ ] Remove `#available` in tests
- [ ] Verify all tests pass on iOS 18 / macOS 15 simulators

### 5. Documentation

- [ ] Update README badges
- [ ] Update ROADMAP.md platform line
- [ ] Update DocC platform annotations

### 6. Version Bump

- [ ] Bump minor version (e.g., 1.0.0 → 1.1.0)
- [ ] Tag release
- [ ] Update dependents' Package.swift

---

## Package Priority

| Priority | Package | Current iOS | Current macOS | Why |
|----------|---------|-------------|---------------|-----|
| 🔴 Critical | AnvilDocs | 13 | 13 | Furthest behind |
| 🟡 High | AnvilTemplate | 16 | 13 | Blocks AnvilDocs |
| 🟡 High | AnvilProject | 16 | 13 | Core infrastructure |
| 🟢 Medium | AnvilWizard | 16 | 13 | CLI tool |
| 🟢 Medium | AnvilNetwork | 16 | 13 | Network layer |
| 🟢 Medium | AnvilFlags | 16 | 13 | Feature flags |
| 🟢 Medium | AnvilDevMenu | 16 | 13 | Dev tool |
| 🟢 Medium | A11yIdentifiers | 16 | 13 | A11y |
| 🟢 Medium | BenchmarkKit | 16 | 13 | Benchmarking |
| 🟢 Medium | AppStrings | 16 | 13 | Localization |

---

## Sprint Schedule

### Sprint 1: AnvilDocs + AnvilTemplate (Week 1-2)

- AnvilDocs: iOS 13 → 18, macOS 13 → 15
- AnvilTemplate: iOS 16 → 18, macOS 13 → 15
- AnvilTemplate: Add `.dictionary` (unblocks AnvilDocs)

### Sprint 2: Core Infrastructure (Week 3-4)

- AnvilProject: iOS 16 → 18, macOS 13 → 15
- AnvilWizard: iOS 16 → 18, macOS 13 → 15

### Sprint 3: Remaining Packages (Week 5-6)

- AnvilNetwork, AnvilFlags, AnvilDevMenu
- A11yIdentifiers, BenchmarkKit, AppStrings

---

## Verification

After each package upgrade:

```bash
swift build
swift test
# Verify no warnings
# Verify no #available / @available in source
grep -r "#available" Sources/ Tests/ || echo "Clean"
grep -r "@available" Sources/ Tests/ || echo "Clean"
```

---

## Post-Upgrade

- [ ] Update MEMORY/07-PACKAGES.md — mark all as iOS 18+ / macOS 15+
- [ ] Update IMPROVEMENT_DASHBOARD.md
- [ ] Update API_MODERNIZATION.md — mark completed items

---

*This sprint is mandatory. No new features until all packages are compliant.*
