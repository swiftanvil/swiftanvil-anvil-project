import Foundation

/// Describes a Swift package project to generate.
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
    ) {
        self.name = name
        self.platforms = platforms
        self.products = products
        self.dependencies = dependencies
        self.targets = targets
        self.includeReadme = includeReadme
        self.includeGitignore = includeGitignore
        self.swiftVersion = swiftVersion
    }
}

/// Describes a product in the package.
public struct ProductSpec: Sendable {
    public var name: String
    public var type: ProductType
    public var targets: [String]
    
    public init(name: String, type: ProductType, targets: [String]) {
        self.name = name
        self.type = type
        self.targets = targets
    }
}

public enum ProductType: Sendable {
    case library
    case executable
}

/// Describes an external package dependency.
public struct DependencySpec: Sendable {
    public var url: String
    public var requirement: DependencyRequirement
    
    public init(url: String, requirement: DependencyRequirement) {
        self.url = url
        self.requirement = requirement
    }
}

public enum DependencyRequirement: Sendable {
    case from(String)
    case exact(String)
    case branch(String)
    case revision(String)
}

/// Describes a target in the package.
public struct TargetSpec: Sendable {
    public var name: String
    public var type: TargetType
    public var dependencies: [TargetDependency]
    public var sources: [String]
    
    public init(
        name: String,
        type: TargetType,
        dependencies: [TargetDependency] = [],
        sources: [String] = []
    ) {
        self.name = name
        self.type = type
        self.dependencies = dependencies
        self.sources = sources
    }
}

public enum TargetType: Sendable {
    case target
    case testTarget
    case executableTarget
}

public enum TargetDependency: Sendable {
    case byName(String)
    case product(String, package: String)
}
