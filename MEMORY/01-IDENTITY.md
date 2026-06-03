---
priority: CRITICAL
type: REFERENCE
audience: BOTH
last_updated: 2026-06-04
---

# SwiftAnvil Identity

## What We Build

SwiftAnvil is a suite of Swift packages for building modern Apple platform apps. We prioritize:

1. **Latest OS first** — iOS 18+, macOS 15+, etc. (see 02-PLATFORM_POLICY.md)
2. **Swift 6 strict concurrency** — no exceptions
3. **Zero dependencies** where possible — pure Swift + Foundation
4. **Test-driven** — every public API has tests
5. **DocC-documented** — every public symbol

## What We Don't Do

- Support old OS versions (see 02-PLATFORM_POLICY.md)
- Use deprecated APIs (see 06-API_MODERNIZATION.md)
- Add dependencies for trivial functionality
- Skip cross-host review
- Merge without tests passing

## Org Structure

- GitHub: github.com/swiftanvil
- Naming: swiftanvil-anvil-<name>
- License: MIT
