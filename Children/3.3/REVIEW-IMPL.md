# Cross-Host Implementation Review: Child 3.3 — AnvilProject

**Reviewer:** Codex CLI (GPT-5.5)  
**Date:** 2026-06-03  
**Verdict:** NEEDS_REVISION → APPROVED_WITH_NOTES (after fixes)  
**Tests:** 37/37 passing (33 original + 4 new)  
**Build:** Clean (warnings only: redundant `await` on non-async InMemoryFileSystem calls)

---

## Review History

- **Round 1 (v1–v11):** Review prompt submitted to Codex CLI ~11 times; output repeatedly truncated before verdict reached.
- **Round 2 (v12):** Review executed in background with output captured to file. Full verdict successfully retrieved.

---

## Original Verdict: NEEDS_REVISION

The implementation passed all 33 tests but could generate SwiftPM manifests or source files that SwiftPM rejects for valid-looking specs. Three P2 correctness issues were identified.

### Blockers (All Resolved)

#### [P2] Product/target type mismatch — `ProjectGenerator.swift:123–128`

**Issue:** When a `.library` product references an `.executableTarget`, or an `.executable` product references a regular `.target`, validation succeeded and the generator emitted a manifest that SwiftPM rejects (e.g. `library product ... should not contain executable targets`).

**Fix:** Added product-type→target-type validation in `validate(spec:at:)`:
- `.library` products may only reference `.target` targets
- `.executable` products may only reference `.executableTarget` targets

**Test added:** `libraryProductReferencesExecutableTarget()`, `executableProductReferencesRegularTarget()`

#### [P2] Non-test target depending on test target — `ProjectGenerator.swift:152–154`

**Issue:** If a regular or executable target declares `.byName("SomeTests")`, validation accepted it because the target name exists, but SwiftPM rejects manifests where non-test targets depend on test targets (`Only test targets can depend on other test targets`).

**Fix:** Added check in the `.byName` dependency validation branch: if `target.type != .testTarget` and the referenced name is in `testTargetNames`, throw `ProjectError.invalidProduct`.

**Test added:** `nonTestTargetDependsOnTestTarget()`

#### [P2] Swift identifier sanitization — `Templates.swift:14`

**Issue:** When a source template is generated for a valid package/target name that is not a valid Swift identifier (e.g. `My-Lib`), the template rendered `public struct My-Lib`, causing compilation failure.

**Fix:** Added `String.sanitizedForSwiftIdentifier` extension (replaces hyphens with underscores) and applied it in `renderTemplate(_:name:)` before passing to AnvilTemplate.

**Test added:** `sanitizesHyphensInIdentifiers()`

---

## Post-Fix Assessment

All three blockers addressed. 37 tests pass. Build is clean aside from pre-existing warnings about redundant `await` on `InMemoryFileSystem` methods (the protocol uses `async` signatures for `FileManagerFileSystem` compatibility, but the in-memory mock is synchronous).

---

## Notes

1. **Test coverage:** The 4 new tests cover all three reported issues. No additional gaps identified.
2. **API design:** `ProjectError.invalidProduct` is reused for both the product→test-target case and the non-test→test-target dependency case. This is acceptable since both represent invalid product configurations, though a dedicated error case could improve specificity in future iterations.
3. **Swift identifier sanitization:** Currently only replaces hyphens. Other invalid characters (spaces, leading digits) are already rejected by the package name regex `[A-Za-z][A-Za-z0-9_-]*`, so this is sufficient for the current validation rules.
