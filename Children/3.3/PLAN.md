# Child 3.3 Plan: Project Generator

## Goal

Build `AnvilProject` — a library that generates complete Swift package projects from a declarative specification. Given a project configuration (name, platforms, dependencies, targets), it creates a working `Package.swift`, directory structure, and source files. This is the engine behind `swiftanvil create app`.

## Non-Goals

- No Xcode project generation (`.xcodeproj`) — Swift Package Manager only
- No UI framework scaffolding (SwiftUI/UIKit views) — just the package structure
- No CI/CD config generation (Child 3.5)
- No Git initialization — caller handles that
- No remote repo creation — caller handles that
- No SwiftPM resource bundling in generated packages
- No external dependency resolution (only syntactic emission)

## What We're Building

A Swift package `AnvilProject` that provides:

1. **Project specification** — `ProjectSpec` struct describing what to create
2. **File generation** — `Package.swift`, directory tree, `README.md`, `.gitignore`, source stubs
3. **Template integration** — uses `AnvilTemplate` for README and source file stubs
4. **File system operations** — safe writes with rollback on failure
5. **Validation** — pre-flight checks (name validity, directory emptiness, structural consistency)

## Project Specification

```swift
public struct ProjectSpec: Sendable {
    public var name: String
    public var platforms: [Platform]
    public var products: [ProductSpec]
    public var dependencies: [DependencySpec]
    public var targets: [TargetSpec]
    public var includeReadme: Bool
    public var includeGitignore: Bool
    public var swiftVersion: String
    
    public init(
        name: String,
        platforms: [Platform] = [.iOS(.v16), .macOS(.v13)],
        products: [ProductSpec] = [],
        dependencies: [DependencySpec] = [],
        targets: [TargetSpec] = [],
        includeReadme: Bool = true,
        includeGitignore: Bool = true,
        swiftVersion: String = "6.0"
    )
}

// Per-platform version enum prevents invalid combinations like .iOS(.v13)
public enum Platform: Sendable {
    case iOS(IOSSupportedVersion)
    case macOS(MacOSSupportedVersion)
    case tvOS(TVOSSupportedVersion)
    case watchOS(WatchOSSupportedVersion)
    case visionOS(VisionOSSupportedVersion)
}

public enum IOSSupportedVersion: Sendable { case v16, v17, v18 }
public enum MacOSSupportedVersion: Sendable { case v13, v14, v15 }
public enum TVOSSupportedVersion: Sendable { case v16, v17, v18 }
public enum WatchOSSupportedVersion: Sendable { case v9, v10, v11 }
public enum VisionOSSupportedVersion: Sendable { case v1, v2 }

public struct ProductSpec: Sendable {
    public var name: String
    public var type: ProductType
    public var targets: [String]
}

public enum ProductType: Sendable {
    case library
    case executable
}

public struct DependencySpec: Sendable {
    public var url: String
    public var requirement: DependencyRequirement
}

public enum DependencyRequirement: Sendable {
    case from(String)
    case exact(String)
    case branch(String)
    case revision(String)
}

public struct TargetSpec: Sendable {
    public var name: String
    public var type: TargetType
    public var dependencies: [TargetDependency]
    public var sources: [String] // template names for source file stubs
}

public enum TargetType: Sendable {
    case target
    case testTarget
    case executableTarget
}

public enum TargetDependency: Sendable {
    case byName(String)
    case product(String, package: String?)
}
```

## File Generation Layout

The generator creates files directly inside the `at` directory (the project root):

```
at/                                ← project root (created if missing, must be empty if exists)
├── Package.swift                  ← programmatic string building
├── README.md                      ← from AnvilTemplate (optional)
├── .gitignore                     ← static string (optional)
├── Sources/
│   └── {TargetName}/              ← for .target and .executableTarget
│       └── {File}.swift           ← from AnvilTemplate stub
└── Tests/
    └── {TargetName}/              ← for .testTarget
        └── {File}.swift           ← from AnvilTemplate stub
```

**Target type → directory mapping:**

| TargetType | Directory | Package.swift syntax |
|-----------|-----------|---------------------|
| `.target` | `Sources/{Name}/` | `.target(name: ...)` |
| `.executableTarget` | `Sources/{Name}/` | `.executableTarget(name: ...)` |
| `.testTarget` | `Tests/{Name}/` | `.testTarget(name: ...)` |

## Architecture Decision: Programmatic Package.swift

`Package.swift` is generated via Swift string building (not AnvilTemplate). Reasons:
- Deeply nested conditionals (dependencies present or not, platforms specified or not)
- Array formatting with proper comma placement and trailing commas
- Easier to unit test programmatic generation
- Template would be unwieldy

AnvilTemplate is used for:
- `README.md` generation
- Source file stubs (default `main.swift` for executables, placeholder for libraries)

## Template Storage Strategy

Templates are **embedded as static strings in Swift source code** (not SwiftPM resources). This avoids `Bundle.module` complexity and keeps the package dependency-free beyond AnvilTemplate.

Built-in templates (defined as `String` constants in `Templates.swift`):
- `readmeTemplate` — README.md with `{{name}}`
- `libraryStubTemplate` — placeholder `public struct {{name}} {}`
- `executableStubTemplate` — `import Foundation; print("Hello, {{name}}!")`
- `testStubTemplate` — empty `@Test` function

Template name → file name mapping: each template produces a file named after the template key. `sources: ["library"]` produces `{TargetName}/library.swift`. `sources: ["main"]` produces `{TargetName}/main.swift`. Multiple templates in `sources` produce multiple files.

Custom template names in `sources: [String]` that don't match built-ins throw `ProjectError.unknownTemplate("name")`.

## File System Safety

- **Atomic writes:** For new files, write content to a same-directory temp file (e.g. `Package.swift.tmp`), then `FileManager.moveItem(at:to:)` to atomically rename into place. For files that may already exist (not typical for generation), use `FileManager.replaceItemAt`. Since all generated files are new in the empty output directory, the temp+move pattern is sufficient.
- **Rollback:** Track every file and directory created. On any error, delete only items the generator created. Do NOT delete a pre-existing empty directory supplied by the caller.
- **File system abstraction:** `FileSystem` protocol wrapping `FileManager` for testability. Tests inject `InMemoryFileSystem` that records operations without touching disk.

```swift
public protocol FileSystem: Sendable {
    func fileExists(at path: URL) -> Bool
    func directoryExists(at path: URL) -> Bool
    func contentsOfDirectory(at path: URL) throws -> [String]
    func createDirectory(at path: URL) throws
    func write(_ content: String, to path: URL) throws
    func removeItem(at path: URL) throws
}
```

## Public API

```swift
import AnvilProject

// Define what to create
let spec = ProjectSpec(
    name: "MyApp",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .init(name: "MyApp", type: .library, targets: ["MyApp"])
    ],
    dependencies: [
        .init(url: "https://github.com/swiftanvil/anvil-network", requirement: .from("1.0.0"))
    ],
    targets: [
        .init(name: "MyApp", type: .target, dependencies: [.product("AnvilNetwork", package: "anvil-network")], sources: ["library"]),
        .init(name: "MyAppTests", type: .testTarget, dependencies: [.byName("MyApp")], sources: ["test"])
    ]
)

// Generate at a path — `at` is the PROJECT ROOT directory, not the parent.
// The generator creates files directly inside `at/` (e.g. `at/Package.swift`).
// If `at` does not exist, it is created. If it exists, it must be empty.
let generator = ProjectGenerator(fileSystem: FileManagerFileSystem())
try generator.generate(spec: spec, at: URL(fileURLWithPath: "/path/to/MyApp"))
```

## Validation

Pre-flight checks before generation:

| Check | Error |
|-------|-------|
| Name is non-empty | `ProjectError.invalidName("name cannot be empty")` |
| Name matches `[A-Za-z][A-Za-z0-9_-]*` | `ProjectError.invalidName("...")` |
| Output directory does not exist OR is empty | `ProjectError.directoryNotEmpty("...")` |
| All target names are unique | `ProjectError.duplicateTarget("...")` |
| All product target references resolve to existing targets | `ProjectError.missingTarget("...")` |
| All `.byName` target dependencies resolve to existing local targets | `ProjectError.missingTarget("...")` |
| All `.product` target dependencies reference a declared package name | `ProjectError.missingDependency("...")` |
| No product references test targets | `ProjectError.invalidProduct("product 'X' references test target 'Y'")` |
| No duplicate product names | `ProjectError.duplicateProduct("...")` |
| No duplicate dependency URLs | `ProjectError.duplicateDependency("...")` |
| All source template names are known | `ProjectError.unknownTemplate("...")` |

## Error Types

```swift
public enum ProjectError: Error, Sendable, Equatable {
    case invalidName(String)
    case directoryNotEmpty(String)
    case duplicateTarget(String)
    case duplicateProduct(String)
    case duplicateDependency(String)
    case missingTarget(String)
    case missingDependency(String)
    case invalidProduct(String)
    case unknownTemplate(String)
    case fileSystemError(String)
    case generationFailed(String)
}
```

## String Escaping

All strings emitted into `Package.swift` are escaped for Swift string literals:
- Backslash → `\\`
- Double quote → `\"`
- Newline → `\n`
- Tab → `\t`

Project names, target names, product names, and URLs all pass through `String.escapeForSwiftLiteral()`.

## Naming

| Aspect | Value |
|--------|-------|
| Repo | `swiftanvil-anvil-project` |
| Module | `AnvilProject` |
| Product | `AnvilProject` library |

## Platforms

iOS 16+, macOS 13+, tvOS 16+, watchOS 9+, visionOS 1+

## Dependencies

- `AnvilTemplate` — for README and source file stub rendering

## Task Breakdown

| # | Task | Est | Success Criteria |
|---|------|-----|------------------|
| 1 | Design `ProjectSpec`, per-platform versions, `ProjectError` | 15 min | All types defined, Sendable, no invalid platform/version combos |
| 2 | Implement `Package.swift` generator (programmatic) | 25 min | Valid Package.swift for library, executable, test target, with/without deps |
| 3 | Implement directory + file creation with `FileSystem` protocol | 15 min | Correct tree per target type, `InMemoryFileSystem` for tests |
| 4 | Implement validation (10 checks) | 20 min | All checks throw correct errors |
| 5 | Implement rollback on failure | 10 min | Only generator-created items deleted; caller dirs preserved |
| 6 | Integrate AnvilTemplate for README + source stubs | 10 min | Built-in templates as static strings, unknown template errors |
| 7 | Write tests (≥15 tests) | 25 min | Spec validation, generation output, rollback, file system mock, edge cases |
| 8 | Write README | 10 min | API docs, usage examples, file layout diagram |
| 9 | Create repo + push | 10 min | GitHub repo |

**Total: ~2.5 hours**

## Success Criteria

- [ ] `swift build` passes with no errors
- [ ] `swift test` passes: ≥15 tests
- [ ] Can generate a valid `Package.swift` for library + executable + test target
- [ ] Can generate with 0, 1, or multiple dependencies
- [ ] Can generate with 0, 1, or multiple platforms
- [ ] Validation catches all invalid inputs with clear errors
- [ ] Failed generation rolls back only generator-created files
- [ ] README with API docs and usage examples
- [ ] Cross-host review APPROVED or APPROVED_WITH_NOTES
