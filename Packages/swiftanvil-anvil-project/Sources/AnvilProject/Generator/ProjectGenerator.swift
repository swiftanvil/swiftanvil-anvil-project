import Foundation
import AnvilTemplate

/// Generates Swift package projects from a declarative specification.
public struct ProjectGenerator: Sendable {
    private let fileSystem: any FileSystem
    
    /// Creates a generator with the given file system.
    public init(fileSystem: any FileSystem) {
        self.fileSystem = fileSystem
    }
    
    /// Generates a project at the given URL.
    /// - Parameters:
    ///   - spec: The project specification.
    ///   - url: The project root directory. Created if missing; must be empty if it exists.
    public func generate(spec: ProjectSpec, at url: URL) async throws {
        try validate(spec: spec, at: url)
        
        var createdItems: [URL] = []
        
        do {
            // Create root directory if it doesn't exist
            if !fileSystem.directoryExists(at: url) {
                try fileSystem.createDirectory(at: url)
                createdItems.append(url)
            }
            
            // Generate Package.swift
            let packageSwift = try generatePackageSwift(spec: spec)
            let packageURL = url.appendingPathComponent("Package.swift")
            try fileSystem.write(packageSwift, to: packageURL)
            createdItems.append(packageURL)
            
            // Generate README.md
            if spec.includeReadme {
                let readme = try generateReadme(spec: spec)
                let readmeURL = url.appendingPathComponent("README.md")
                try fileSystem.write(readme, to: readmeURL)
                createdItems.append(readmeURL)
            }
            
            // Generate .gitignore
            if spec.includeGitignore {
                let gitignoreURL = url.appendingPathComponent(".gitignore")
                try fileSystem.write(Templates.gitignoreTemplate, to: gitignoreURL)
                createdItems.append(gitignoreURL)
            }
            
            // Generate target directories and source files
            for target in spec.targets {
                let targetDir: URL
                switch target.type {
                case .target, .executableTarget:
                    targetDir = url.appendingPathComponent("Sources").appendingPathComponent(target.name)
                case .testTarget:
                    targetDir = url.appendingPathComponent("Tests").appendingPathComponent(target.name)
                }
                
                if !fileSystem.directoryExists(at: targetDir) {
                    try fileSystem.createDirectory(at: targetDir)
                    createdItems.append(targetDir)
                }
                
                for sourceTemplate in target.sources {
                    guard let templateString = Templates.template(named: sourceTemplate) else {
                        throw ProjectError.unknownTemplate(sourceTemplate)
                    }
                    let fileName = sourceTemplate + ".swift"
                    let fileURL = targetDir.appendingPathComponent(fileName)
                    let rendered = try renderTemplate(templateString, name: target.name)
                    try fileSystem.write(rendered, to: fileURL)
                    createdItems.append(fileURL)
                }
            }
            
        } catch {
            // Rollback: delete created items in reverse order
            for item in createdItems.reversed() {
                try? fileSystem.removeItem(at: item)
            }
            throw ProjectError.generationFailed("\(error)")
        }
    }
    
    // MARK: - Validation
    
    private func validate(spec: ProjectSpec, at url: URL) throws {
        // Name validation
        guard !spec.name.isEmpty else {
            throw ProjectError.invalidName("name cannot be empty")
        }
        let namePattern = /^[A-Za-z][A-Za-z0-9_-]*$/
        guard spec.name.firstMatch(of: namePattern) != nil else {
            throw ProjectError.invalidName("'\(spec.name)' is not a valid Swift package name")
        }
        
        // Directory validation
        if fileSystem.directoryExists(at: url) {
            let contents = try? fileSystem.contentsOfDirectory(at: url)
            if let contents = contents, !contents.isEmpty {
                throw ProjectError.directoryNotEmpty("directory '\(url.path)' is not empty")
            }
        }
        
        // Target uniqueness
        let targetNames = spec.targets.map(\.name)
        let duplicateTargets = Dictionary(grouping: targetNames, by: { $0 }).filter { $0.value.count > 1 }.keys
        if let dup = duplicateTargets.first {
            throw ProjectError.duplicateTarget("duplicate target '\(dup)'")
        }
        
        // Product target references
        let targetNameSet = Set(targetNames)
        for product in spec.products {
            for targetName in product.targets {
                guard targetNameSet.contains(targetName) else {
                    throw ProjectError.missingTarget("product '\(product.name)' references unknown target '\(targetName)'")
                }
            }
        }
        
        // Product must not reference test targets
        let testTargetNames = Set(spec.targets.filter { $0.type == .testTarget }.map(\.name))
        for product in spec.products {
            for targetName in product.targets {
                if testTargetNames.contains(targetName) {
                    throw ProjectError.invalidProduct("product '\(product.name)' references test target '\(targetName)'")
                }
            }
        }
        
        // Duplicate product names
        let productNames = spec.products.map(\.name)
        let duplicateProducts = Dictionary(grouping: productNames, by: { $0 }).filter { $0.value.count > 1 }.keys
        if let dup = duplicateProducts.first {
            throw ProjectError.duplicateProduct("duplicate product '\(dup)'")
        }
        
        // Duplicate dependency URLs
        let dependencyURLs = spec.dependencies.map(\.url)
        let duplicateDeps = Dictionary(grouping: dependencyURLs, by: { $0 }).filter { $0.value.count > 1 }.keys
        if let dup = duplicateDeps.first {
            throw ProjectError.duplicateDependency("duplicate dependency '\(dup)'")
        }
        
        // Target dependency validation
        let dependencyPackageNames = Set(spec.dependencies.map { packageName(from: $0.url) })
        for target in spec.targets {
            for dep in target.dependencies {
                switch dep {
                case .byName(let name):
                    guard targetNameSet.contains(name) else {
                        throw ProjectError.missingTarget("target '\(target.name)' depends on unknown target '\(name)'")
                    }
                case .product(_, let package):
                    guard dependencyPackageNames.contains(package) else {
                        throw ProjectError.missingDependency("target '\(target.name)' depends on undeclared package '\(package)'")
                    }
                }
            }
        }
        
        // Unknown templates
        for target in spec.targets {
            for source in target.sources {
                if Templates.template(named: source) == nil {
                    throw ProjectError.unknownTemplate("unknown template '\(source)' in target '\(target.name)'")
                }
            }
        }
    }
    
    // MARK: - Package.swift Generation
    
    private func generatePackageSwift(spec: ProjectSpec) throws -> String {
        var lines: [String] = []
        lines.append("// swift-tools-version: \(spec.swiftVersion)")
        lines.append("import PackageDescription")
        lines.append("")
        lines.append("let package = Package(")
        lines.append("    name: \"\(spec.name.escapedForSwiftLiteral())\",")
        
        // Platforms
        if !spec.platforms.isEmpty {
            lines.append("    platforms: [")
            for (index, platform) in spec.platforms.enumerated() {
                let comma = index < spec.platforms.count - 1 ? "," : ""
                lines.append("        .\(platform.platformName)(.v\(platform.versionNumber))\(comma)")
            }
            lines.append("    ],")
        }
        
        // Products
        if spec.products.isEmpty {
            lines.append("    products: [],")
        } else {
            lines.append("    products: [")
            for (index, product) in spec.products.enumerated() {
                let comma = index < spec.products.count - 1 ? "," : ""
                let typeName = product.type == .library ? "library" : "executable"
                let targets = product.targets.map { "\"\($0.escapedForSwiftLiteral())\"" }.joined(separator: ", ")
                lines.append("        .\(typeName)(name: \"\(product.name.escapedForSwiftLiteral())\", targets: [\(targets)])\(comma)")
            }
            lines.append("    ],")
        }
        
        // Dependencies
        if spec.dependencies.isEmpty {
            lines.append("    dependencies: [],")
        } else {
            lines.append("    dependencies: [")
            for (index, dep) in spec.dependencies.enumerated() {
                let comma = index < spec.dependencies.count - 1 ? "," : ""
                let req = dependencyRequirementString(dep.requirement)
                lines.append("        .package(url: \"\(dep.url.escapedForSwiftLiteral())\", \(req))\(comma)")
            }
            lines.append("    ],")
        }
        
        // Targets
        if spec.targets.isEmpty {
            lines.append("    targets: []")
        } else {
            lines.append("    targets: [")
            for (index, target) in spec.targets.enumerated() {
                let comma = index < spec.targets.count - 1 ? "," : ""
                let targetTypeName: String
                switch target.type {
                case .target: targetTypeName = "target"
                case .testTarget: targetTypeName = "testTarget"
                case .executableTarget: targetTypeName = "executableTarget"
                }
                
                if target.dependencies.isEmpty {
                    lines.append("        .\(targetTypeName)(name: \"\(target.name.escapedForSwiftLiteral())\")\(comma)")
                } else {
                    let deps = target.dependencies.map { dependencyString($0) }.joined(separator: ", ")
                    lines.append("        .\(targetTypeName)(name: \"\(target.name.escapedForSwiftLiteral())\", dependencies: [\(deps)])\(comma)")
                }
            }
            lines.append("    ]")
        }
        
        lines.append(")")
        return lines.joined(separator: "\n") + "\n"
    }
    
    private func dependencyRequirementString(_ req: DependencyRequirement) -> String {
        switch req {
        case .from(let version):
            return "from: \"\(version.escapedForSwiftLiteral())\""
        case .exact(let version):
            return "exact: \"\(version.escapedForSwiftLiteral())\""
        case .branch(let branch):
            return "branch: \"\(branch.escapedForSwiftLiteral())\""
        case .revision(let revision):
            return "revision: \"\(revision.escapedForSwiftLiteral())\""
        }
    }
    
    private func dependencyString(_ dep: TargetDependency) -> String {
        switch dep {
        case .byName(let name):
            return "\"\(name.escapedForSwiftLiteral())\""
        case .product(let name, let package):
            return ".product(name: \"\(name.escapedForSwiftLiteral())\", package: \"\(package.escapedForSwiftLiteral())\")"
        }
    }
    
    // MARK: - README Generation
    
    private func generateReadme(spec: ProjectSpec) throws -> String {
        guard let templateString = Templates.template(named: "readme") else {
            throw ProjectError.unknownTemplate("readme")
        }
        return try renderTemplate(templateString, name: spec.name)
    }
    
    // MARK: - Helpers
    
    private func renderTemplate(_ templateString: String, name: String) throws -> String {
        let template = try Template(templateString)
        return try template.render(context: ["name": name])
    }
    
    private func packageName(from url: String) -> String {
        // Extract package name from URL: https://github.com/user/repo.git → repo
        let trimmed = url.trimmingCharacters(in: .whitespaces)
        let withoutSuffix = trimmed.hasSuffix(".git") ? String(trimmed.dropLast(4)) : trimmed
        let components = withoutSuffix.split(separator: "/")
        return String(components.last ?? "")
    }
}

// MARK: - String Escaping

extension String {
    /// Escapes this string for use as a Swift string literal.
    func escapedForSwiftLiteral() -> String {
        self
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\t", with: "\\t")
    }
}
