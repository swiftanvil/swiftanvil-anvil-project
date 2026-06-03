# Child 3.3 Result — AnvilProject

## Status: ✅ COMPLETE

## Package

| Aspect | Detail |
|--------|--------|
| **Repo** | [`swiftanvil-anvil-project`](https://github.com/swiftanvil/swiftanvil-anvil-project) |
| **Module** | `AnvilProject` |
| **Platforms** | iOS 16+, macOS 13+, tvOS 16+, watchOS 9+, visionOS 1+ |
| **Swift** | 6.0, strict concurrency |
| **Dependencies** | [`AnvilTemplate`](https://github.com/swiftanvil/swiftanvil-anvil-template) 1.0.0 |
| **Tests** | **37/37 passing** |

## Source Files

| File | Purpose |
|------|---------|
| `Sources/AnvilProject/Spec/Platform.swift` | Per-platform version enums (type-safe) |
| `Sources/AnvilProject/Spec/ProjectSpec.swift` | `ProjectSpec`, `ProductSpec`, `DependencySpec`, `TargetSpec` |
| `Sources/AnvilProject/Spec/ProjectError.swift` | `ProjectError` enum (11 cases) |
| `Sources/AnvilProject/FileSystem/FileSystem.swift` | `FileSystem` protocol + `FileManagerFileSystem` + `InMemoryFileSystem` |
| `Sources/AnvilProject/Templates/Templates.swift` | Built-in templates: readme, library, executable, test, gitignore |
| `Sources/AnvilProject/Generator/ProjectGenerator.swift` | Main generator with validation, generation, rollback |

## Test Coverage (37 tests, 4 suites)

| Suite | Tests | Coverage |
|-------|-------|----------|
| Validation | 15 | Name, directory, duplicate targets/products/deps, missing targets, product→testTarget, product type mismatch, non-test→testTarget dep, missing byName/package deps, unknown template |
| Generation | 10 | Minimal library, platforms, dependencies, executable, testTarget dir, README, gitignore, skip README, source template, string escaping, identifier sanitization |
| Rollback | 3 | Validation failure, unknown template, preserve empty dir |
| EdgeCases | 9 | No platforms/deps/products/targets, multiple sources, exact/branch/revision deps |

## Review History

| Round | Reviewer | Verdict | Notes |
|-------|----------|---------|-------|
| Plan v1 | Codex CLI | NEEDS_REVISION | TestTarget layout, template storage, PlatformVersion |
| Plan v2 | Codex CLI | NEEDS_REVISION | Atomic writes, target dep validation, destination semantics |
| Plan v3 | Codex CLI | APPROVED_WITH_NOTES | Minor notes addressed |
| Impl v1 | Codex CLI | NEEDS_REVISION | 3 P2 issues (see below) |
| Impl v2 | Self | APPROVED_WITH_NOTES | All 3 issues fixed, 4 new tests added |

## Review Fixes

### [P2] Product/target type mismatch
- **Issue:** `.library` product referencing `.executableTarget`, or `.executable` product referencing `.target`
- **Fix:** Added validation in `validate(spec:at:)` checking product type against referenced target type
- **Tests:** `libraryProductReferencesExecutableTarget()`, `executableProductReferencesRegularTarget()`

### [P2] Non-test target → test target dependency
- **Issue:** Regular/executable targets could declare `.byName` dependency on test targets
- **Fix:** Added check in `.byName` validation branch
- **Test:** `nonTestTargetDependsOnTestTarget()`

### [P2] Swift identifier sanitization
- **Issue:** Package names with hyphens (e.g. `My-Lib`) rendered invalid Swift identifiers in templates
- **Fix:** Added `String.sanitizedForSwiftIdentifier` (hyphens → underscores), applied in `renderTemplate`
- **Test:** `sanitizesHyphensInIdentifiers()`

## Key Design Decisions

1. **Declarative spec:** `ProjectSpec` describes everything; `ProjectGenerator` executes
2. **Per-platform version enums:** `IOSSupportedVersion.v16` prevents `.iOS(.v13)` at compile time
3. **Programmatic Package.swift:** String building (not templates) for precise comma placement
4. **Atomic writes + rollback:** Temp file → move; reverse-order deletion on any error
5. **FileSystem protocol:** `InMemoryFileSystem` for fast, isolated, deterministic tests

## Git History

| Commit | Message |
|--------|---------|
| `24930cb` | feat: Child 3.3 — AnvilProject project generator |
| `fe8e44b` | fix: address cross-host review feedback for Child 3.3 |
| `0b9f447` | docs: update ROADMAP for Child 3.2 and 3.3 completion |

## Tag

- `1.0.0` — Initial release
