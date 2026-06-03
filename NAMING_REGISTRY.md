# Naming Registry — SwiftAnvil

> **Single source of truth for all names.** Change it here, it propagates everywhere.

---

## Core Principle

**No name is hardcoded twice.** Every name used in code, docs, URLs, or commands is defined in this registry and referenced via lookup.

If a name changes (e.g., `iFoundation` → `SwiftAnvilCLI`), update this file once. The next session, every AI reads the new name and uses it correctly.

---

## Registry Format

Each entry has:
- **Key**: Machine-readable identifier (snake_case, never changes)
- **Value**: Current human-readable name
- **Type**: `org` | `repo` | `product` | `module` | `cli` | `domain` | `package_prefix`
- **Stability**: `stable` | `evolving` | `deprecated`
- **Used in**: Where this name appears (files, code, docs)
- **Aliases**: Previous names (for search/replace during migration)

---

## Organization Names

| Key | Value | Type | Stability | Used In | Aliases |
|-----|-------|------|-----------|---------|---------|
| `ORG_NAME` | SwiftAnvil | org | stable | GitHub org, docs, branding | iFoundation |
| `ORG_DOMAIN` | swiftanvil.org | domain | stable | Website, docs | — |
| `ORG_GITHUB` | github.com/swiftanvil | domain | stable | GitHub URLs | github.com/iFoundation |

## CLI Tool Names

| Key | Value | Type | Stability | Used In | Aliases |
|-----|-------|------|-----------|---------|---------|
| `CLI_NAME` | swiftanvil | cli | stable | Command name, binary name | ifoundation |
| `CLI_MODULE` | SwiftAnvilCLI | module | stable | Swift module name | iFoundation |
| `CLI_PRODUCT` | swiftanvil-cli | repo | stable | GitHub repo name | iFoundation |

## Package Names

| Key | Value | Type | Stability | Used In | Aliases |
|-----|-------|------|-----------|---------|---------|
| `PKG_PREFIX` | swiftanvil-anvil- | package_prefix | stable | All package repos | ifoundation- |
| `PKG_A11Y` | swiftanvil-anvil-a11y | repo | stable | GitHub, Package.swift | ifoundation-a11yidentifiers |
| `PKG_BENCH` | swiftanvil-anvil-bench | repo | stable | GitHub, Package.swift | ifoundation-benchmarkkit |
| `PKG_STRINGS` | swiftanvil-anvil-strings | repo | stable | GitHub, Package.swift | ifoundation-appstrings |
| `PKG_NETWORK` | swiftanvil-anvil-network | repo | stable | GitHub, Package.swift | — |
| `PKG_FLAGS` | swiftanvil-anvil-flags | repo | stable | GitHub, Package.swift | — |
| `PKG_DEVMENU` | swiftanvil-anvil-devmenu | repo | stable | GitHub, Package.swift | — |
| `PKG_WIZARD` | swiftanvil-anvil-wizard | repo | stable | GitHub, Package.swift | — |
| `PKG_TEMPLATE` | swiftanvil-anvil-template | repo | stable | GitHub, Package.swift | — |
| `PKG_PROJECT` | swiftanvil-anvil-project | repo | stable | GitHub, Package.swift | — |
| `PKG_DOCS` | swiftanvil-anvil-docs | repo | stable | GitHub, Package.swift | — |

## Module Names

| Key | Value | Type | Stability | Used In | Aliases |
|-----|-------|------|-----------|---------|---------|
| `MOD_A11Y` | A11yIdentifiers | module | stable | Swift import, code | — |
| `MOD_BENCH` | BenchmarkKit | module | stable | Swift import, code | — |
| `MOD_STRINGS` | AppStrings | module | stable | Swift import, code | — |
| `MOD_NETWORK` | AnvilNetwork | module | stable | Swift import, code | — |
| `MOD_FLAGS` | AnvilFlags | module | stable | Swift import, code | — |
| `MOD_DEVMENU` | AnvilDevMenu | module | stable | Swift import, code | — |
| `MOD_WIZARD` | AnvilWizard | module | stable | Swift import, code | — |
| `MOD_TEMPLATE` | AnvilTemplate | module | stable | Swift import, code | — |
| `MOD_PROJECT` | AnvilProject | module | stable | Swift import, code | — |
| `MOD_DOCS` | AnvilDocs | module | stable | Swift import, code | — |

## Product Names

| Key | Value | Type | Stability | Used In | Aliases |
|-----|-------|------|-----------|---------|---------|
| `PROD_A11Y` | A11yIdentifiers | product | stable | Package.swift products | — |
| `PROD_BENCH` | BenchmarkKit | product | stable | Package.swift products | — |
| `PROD_STRINGS` | AppStrings | product | stable | Package.swift products | — |
| `PROD_NETWORK` | AnvilNetwork | product | stable | Package.swift products | — |
| `PROD_FLAGS` | AnvilFlags | product | stable | Package.swift products | — |
| `PROD_DEVMENU` | AnvilDevMenu | product | stable | Package.swift products | — |
| `PROD_WIZARD` | AnvilWizard | product | stable | Package.swift products | — |
| `PROD_TEMPLATE` | AnvilTemplate | product | stable | Package.swift products | — |
| `PROD_PROJECT` | AnvilProject | product | stable | Package.swift products | — |
| `PROD_DOCS` | AnvilDocs | product | stable | Package.swift products | — |

## Directory Names

| Key | Value | Type | Stability | Used In | Aliases |
|-----|-------|------|-----------|---------|---------|
| `DIR_PACKAGES` | Packages/swiftanvil/ | path | stable | Local directory structure | Packages/ |
| `DIR_MEMORY` | MEMORY/ | path | stable | Memory system | — |
| `DIR_CHILDREN` | Children/ | path | stable | Child tracking | — |

---

## Naming Rules

### 1. Repo Naming

```
{ORG}-{PREFIX}-{NAME}
```

Example: `swiftanvil-anvil-template`

### 2. Module Naming

```
Anvil{PascalCaseName}
```

Example: `AnvilTemplate`, `AnvilProject`

Exception: Packages that existed before the org use their original name (`A11yIdentifiers`, `AppStrings`, `BenchmarkKit`).

### 3. Product Naming

Same as module name for libraries.

### 4. CLI Naming

```
{ORG} <command> <subcommand>
```

Example: `swiftanvil create MyApp --template ios-app`

---

## Migration System

When a name changes:

1. Update this registry (change `Value`, add to `Aliases`)
2. Run audit to find all occurrences of old name:
   ```bash
   grep -r "OLD_NAME" --include="*.md" --include="*.swift" --include="*.json" .
   ```
3. Replace in priority order:
   - Active source code (Package.swift, Sources/, Tests/)
   - package.readme files
   - GitHub URLs in docs
   - Historical docs (Children/, Composed/) — mark as archived
4. Update `packages.registry`
5. Commit with message: `Naming migration: OLD → NEW`

---

## Enforcement

### Build-Time

No enforcement yet (static strings). Future:
```bash
swiftanvil lint --naming
# Checks for hardcoded names not in registry
```

### Review-Time

Reviewer checklist:
- [ ] No hardcoded `iFoundation` in new code
- [ ] No hardcoded `ifoundation` in new code
- [ ] GitHub URLs use `github.com/swiftanvil`
- [ ] Package names use `swiftanvil-anvil-*` prefix

### AI Memory

The AI reads this file at session start (part of `packages.registry` or dedicated `naming.registry`).

If AI generates code with old names:
- Self-correct during implementation
- Flag in review if missed

---

## Current Drift Audit

| Old Name | New Name | Occurrences | Status |
|----------|----------|-------------|--------|
| `iFoundation` | `SwiftAnvilCLI` or `swiftanvil` | ~350 | 🔴 Active drift |
| `ifoundation-*` | `swiftanvil-anvil-*` | ~50 | 🔴 Active drift |
| `github.com/iFoundation` | `github.com/swiftanvil` | ~20 | 🔴 Active drift |

**Action:** Naming cleanup sprint required. See `upgrade.platform` for scheduling.

---

*This registry is the single source of truth. If it's not here, it's not official.*
