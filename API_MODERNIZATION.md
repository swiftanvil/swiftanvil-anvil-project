# API Modernization Log — SwiftAnvil Org

> Track deprecated APIs and their modern replacements across all packages. Updated during cleanup sprints.

---

## Global Patterns to Modernize

These apply to **all** SwiftAnvil packages when minimum OS rises.

| Pattern | Old API | Modern Replacement | Min OS | Status |
|---------|---------|-------------------|--------|--------|
| JSON parsing | `JSONSerialization` | `JSONDecoder` / `Codable` | iOS 15+ | ⏳ Pending org-wide |
| Regex | `NSRegularExpression` | `RegexBuilder` / `Regex` | iOS 16+ | ⏳ Pending org-wide |
| String splitting | `components(separatedBy:)` | `split(separator:)` | iOS 15+ | ⏳ Pending org-wide |
| Async networking | `URLSession` completion handlers | `data(for:)` / `bytes(for:)` | iOS 15+ | ⏳ Pending org-wide |
| Observation | `ObservableObject` + `@Published` | `@Observable` macro | iOS 17+ | ⏳ Pending org-wide |
| Testing | `XCTest` | Swift Testing `#expect` | iOS 15+ | ✅ Adopted |
| Concurrency | `DispatchQueue` | `Task` / `async` | iOS 15+ | ✅ Adopted |

---

## Per-Package Modernization

### AnvilTemplate

| API | Current File | Replacement | Status | Ticket |
|-----|-------------|-------------|--------|--------|
| `JSONSerialization` | TargetDiscovery.swift | `JSONDecoder` + `Codable` structs | ⏳ | TPL-MOD-001 |
| `String.components` | TemplateParser.swift | `split(separator:)` | ⏳ | TPL-MOD-002 |

### AnvilProject

| API | Current File | Replacement | Status | Ticket |
|-----|-------------|-------------|--------|--------|
| `FileManager` synchronous | FileSystem.swift | Modern `FileManager` async APIs | ⏳ | PRJ-MOD-001 |

### AnvilDocs

| API | Current File | Replacement | Status | Ticket |
|-----|-------------|-------------|--------|--------|
| `Process` + `Pipe` | ProcessRunner.swift | `Process` with modern async patterns | ✅ | Done in v1.0 |
| `JSONSerialization` | TargetDiscovery.swift | `JSONDecoder` + `Codable` structs | ⏳ | DOC-MOD-001 |

---

## Cleanup Sprint Schedule

| Trigger | Action | Packages Affected |
|---------|--------|-------------------|
| iOS 27 GM release | Drop iOS 18, adopt iOS 27 APIs | All |
| Swift 6.1 release | Adopt new language features | All |
| Package score < 80 | Modernize as part of improvement sprint | Specific |

---

## How to Add an Entry

1. Discover old API during code review or audit
2. Add row to this file with status ⏳
3. Create improvement item in `package.improvement-score`
4. Schedule during next cleanup sprint
5. Update status to ✅ when done

---

*This file is the source of truth for what needs modernizing. If it's not here, it's not tracked.*
