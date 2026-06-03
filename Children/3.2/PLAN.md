# Child 3.2 Plan: Template Engine

## Goal

Build a lightweight template engine for `swiftanvil` that generates boilerplate code from template strings. This child covers the core parser, renderer, and context only. Built-in templates and resource packaging move to Child 3.3.

## Non-Goals

- No built-in template files (Child 3.3)
- No resource bundling (Child 3.3)
- No project scaffolding (Child 3.3)
- No DocC generation (Child 3.4)

## What We're Building

A Swift package `AnvilTemplate` that provides:

1. **Template syntax** — `{{variable}}` substitution, `{{#if variable}}...{{/if}}` conditionals, `{{#each items}}...{{/each}}` loops
2. **Template parsing** — string → AST with clear error messages
3. **Context** — typed key-value storage for template variables
4. **Rendering modes** — strict (fail on missing) vs lenient (empty string for missing)

## Template Syntax

```
// Variable substitution
{{name}}

// Conditionals
{{#if useSwiftUI}}
import SwiftUI
{{/if}}

// Loops
{{#each dependencies}}
    .package(url: "https://github.com/swiftanvil/{{.}}", from: "1.0.0"),
{{/each}}

// Comments (not rendered)
{{! This is a comment }}
```

## Supported Value Types

| Type | Render Behavior |
|------|-----------------|
| `String` | Rendered as-is |
| `Bool` | `true` → "true", `false` → "false". Used in `#if` |
| `Int`, `Double` | String representation |
| `[String]` | Iterated by `#each`. Inside loop, `{{.}}` is current element |
| `nil` / missing | Strict: error. Lenient: empty string |

## Parser Error Cases (all throw `TemplateError.parseError`)

| Case | Example | Error |
|------|---------|-------|
| Unclosed tag | `{{name` | "Unclosed tag at position N" |
| Empty tag | `{{}}` | "Empty tag at position N" |
| Unknown directive | `{{#foo}}` | "Unknown directive 'foo'" |
| Mismatched closing | `{{/if}}` without `{{#if}}` | "Unexpected closing tag '/if'" |
| Unclosed conditional | `{{#if x}}...` (no `{{/if}}`) | "Unclosed block 'if'" |
| Unclosed loop | `{{#each items}}...` (no `{{/each}}`) | "Unclosed block 'each'" |
| Mismatched block | `{{#if x}}...{{/each}}` | "Expected '/if', found '/each'" |
| Nested blocks | `{{#if a}}{{#if b}}` | "Nested blocks not supported" |
| Invalid variable name | `{{123}}` | "Invalid variable name '123'" |
| Comment in block | `{{#if x}}{{! comment}}{{/if}}` | "Comments inside blocks not supported" |

## Public API Surface

```swift
import AnvilTemplate

// From string
let template = try Template("Hello, {{name}}!")
let context = TemplateContext(["name": "World"])
let output = try template.render(context: context)
// "Hello, World!"

// From URL
let template = try Template(contentsOf: URL(fileURLWithPath: "template.txt"))

// Strict mode
let template = try Template("{{name}} {{version}}")
try template.render(context: ["name": "App"], mode: .strict)
// throws TemplateError.missingVariable("version")

// With loop
let template = try Template("{{#each items}}{{.}} {{/each}}")
let output = try template.render(context: ["items": ["a", "b", "c"]])
// "a b c "
```

## Architecture

```
AnvilTemplate
├── Core/
│   ├── Template.swift           # Parse + render entry point
│   ├── TemplateContext.swift    # Variable storage with typed access
│   ├── TemplateError.swift      # Parse/render errors
│   └── RenderMode.swift         # .strict / .lenient
├── AST/
│   ├── TemplateNode.swift       # AST enum: text, variable, conditional, loop
│   └── TemplateValue.swift      # Renderable value types
├── Parser/
│   └── TemplateParser.swift     # String → AST
└── Renderer/
    └── TemplateRenderer.swift   # AST + Context → String (testable independently)
```

## Naming

| Aspect | Value |
|--------|-------|
| Repo | `swiftanvil-anvil-template` |
| Module | `AnvilTemplate` |
| Product | `AnvilTemplate` library |

## Platforms

iOS 16+, macOS 13+, tvOS 16+, watchOS 9+, visionOS 1+

## Dependencies

None. Pure Swift + Foundation.

## Task Breakdown

| # | Task | Est | Success Criteria |
|---|------|-----|------------------|
| 1 | Design AST (`TemplateNode`, `TemplateValue`) | 15 min | Enum covers text, var, if, each |
| 2 | Implement parser with all error cases | 25 min | All 10 error cases throw correctly |
| 3 | Implement `TemplateContext` | 10 min | `get<T>()` with type safety |
| 4 | Implement renderer (AST → string) | 20 min | Var sub, conditionals, loops |
| 5 | Implement strict/lenient modes | 10 min | `.strict` throws, `.lenient` empty string |
| 6 | Add `Template(contentsOf:)` | 5 min | Reads file, parses |
| 7 | Write tests (≥15 tests) | 20 min | Parse, render, errors, modes, loops |
| 8 | Write README | 10 min | Syntax reference, API, error cases |
| 9 | Create repo + push | 10 min | GitHub repo, .gitignore |

**Total: ~2 hours**

## Success Criteria

- [x] `swift build` passes with no errors
- [x] `swift test` passes: 30 tests (≥15 target met)
- [x] Can render template with variables, conditionals, and loops
- [x] All parser error cases produce clear messages
- [x] Strict mode fails fast on missing variables
- [x] README with syntax reference + API docs
- [x] Cross-host review APPROVED_WITH_NOTES (Codex CLI, GPT-5.5)
- [x] GitHub repo created and pushed: https://github.com/swiftanvil/swiftanvil-anvil-template

## Post-Review Fixes

- **Whitespace-tolerant closing tags**: Fixed parser to accept `{{ /if }}` and `{{/if }}` (not just exact `{{/if}}`). Added 2 tests.
- **Comments in blocks**: Rejected by design per PLAN; documented rationale in REVIEW-IMPL.md.
