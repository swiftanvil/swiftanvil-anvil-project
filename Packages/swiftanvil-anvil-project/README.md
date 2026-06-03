# AnvilProject

A declarative Swift package project generator for the swiftanvil ecosystem. Given a `ProjectSpec`, it creates a complete, valid Swift package with `Package.swift`, directory structure, source files, README, and `.gitignore`.

## Usage

```swift
import AnvilProject

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

let generator = ProjectGenerator(fileSystem: FileManagerFileSystem())
try generator.generate(spec: spec, at: URL(fileURLWithPath: "/path/to/MyApp"))
```

## Generated Layout

```
MyApp/
├── Package.swift          ← programmatically generated
├── README.md              ← from template (optional)
├── .gitignore             ← static content (optional)
├── Sources/
│   └── MyApp/
│       └── library.swift  ← from built-in template
└── Tests/
    └── MyAppTests/
        └── test.swift     ← from built-in template
```

## ProjectSpec

| Property | Type | Default |
|----------|------|---------|
| `name` | `String` | required |
| `platforms` | `[Platform]` | `[.iOS(.v16), .macOS(.v13)]` |
| `products` | `[ProductSpec]` | `[]` |
| `dependencies` | `[DependencySpec]` | `[]` |
| `targets` | `[TargetSpec]` | `[]` |
| `includeReadme` | `Bool` | `true` |
| `includeGitignore` | `Bool` | `true` |
| `swiftVersion` | `String` | `"6.0"` |

## Platforms

Per-platform version enums prevent invalid combinations at compile time:

```swift
.iOS(.v16)        // v16, v17, v18
.macOS(.v13)      // v13, v14, v15
.tvOS(.v16)       // v16, v17, v18
.watchOS(.v9)     // v9, v10, v11
.visionOS(.v1)    // v1, v2
```

## Target Types

| Type | Directory | Package.swift |
|------|-----------|---------------|
| `.target` | `Sources/{Name}/` | `.target(name: ...)` |
| `.executableTarget` | `Sources/{Name}/` | `.executableTarget(name: ...)` |
| `.testTarget` | `Tests/{Name}/` | `.testTarget(name: ...)` |

## Built-in Source Templates

Template names in `TargetSpec.sources` map to built-in templates:

| Name | Content |
|------|---------|
| `"library"` | `public struct {Name} { init() {} }` |
| `"executable"` | `print("Hello, {name}!")` |
| `"test"` | `@Test func example() async throws {}` |

Each template name produces a file: `sources: ["library"]` → `{TargetName}/library.swift`.

## Validation

Pre-flight checks (all throw `ProjectError`):

- Name is non-empty and valid `[A-Za-z][A-Za-z0-9_-]*`
- Output directory does not exist or is empty
- All target names are unique
- All product target references exist
- No product references test targets
- No duplicate product names or dependency URLs
- All `.byName` dependencies resolve to local targets
- All `.product` dependencies reference declared packages
- All source template names are known

## File System Safety

- **Atomic writes:** Content written to same-directory temp file, then moved into place
- **Rollback:** On any error, all generator-created files/directories are deleted. Pre-existing empty directories are preserved.
- **Testability:** `FileSystem` protocol with `InMemoryFileSystem` for fast, isolated tests

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

## Platforms

iOS 16+, macOS 13+, tvOS 16+, watchOS 9+, visionOS 1+

## Dependencies

- [AnvilTemplate](https://github.com/swiftanvil/swiftanvil-anvil-template) — for README and source stub rendering
