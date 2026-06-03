import Foundation
import Testing
@testable import AnvilProject

// MARK: - Validation Tests

@Suite("Validation")
struct ValidationTests {
    let fs = InMemoryFileSystem()
    
    func generator() -> ProjectGenerator {
        ProjectGenerator(fileSystem: fs)
    }
    
    @Test("accepts valid spec")
    func validSpec() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            products: [.init(name: "MyApp", type: .library, targets: ["MyApp"])],
            targets: [.init(name: "MyApp", type: .target, sources: ["library"])]
        )
        let url = URL(fileURLWithPath: "/test/MyApp")
        try await generator().generate(spec: spec, at: url)
        #expect(await fs.directoryExists(at: url))
    }
    
    @Test("rejects empty name")
    func emptyName() async {
        let spec = ProjectSpec(name: "")
        let url = URL(fileURLWithPath: "/test/Empty")
        await #expect(throws: ProjectError.invalidName("name cannot be empty")) {
            try await generator().generate(spec: spec, at: url)
        }
    }
    
    @Test("rejects invalid name")
    func invalidName() async {
        let spec = ProjectSpec(name: "123App")
        let url = URL(fileURLWithPath: "/test/Bad")
        await #expect(throws: ProjectError.invalidName("'123App' is not a valid Swift package name")) {
            try await generator().generate(spec: spec, at: url)
        }
    }
    
    @Test("rejects non-empty directory")
    func nonEmptyDirectory() async throws {
        let url = URL(fileURLWithPath: "/test/Exists")
        try await fs.createDirectory(at: url)
        try await fs.write("existing", to: url.appendingPathComponent("file.txt"))
        
        let spec = ProjectSpec(name: "MyApp")
        await #expect(throws: ProjectError.directoryNotEmpty("directory '/test/Exists' is not empty")) {
            try await generator().generate(spec: spec, at: url)
        }
    }
    
    @Test("rejects duplicate targets")
    func duplicateTargets() async {
        let spec = ProjectSpec(
            name: "MyApp",
            targets: [
                .init(name: "MyApp", type: .target),
                .init(name: "MyApp", type: .target)
            ]
        )
        let url = URL(fileURLWithPath: "/test/Dup")
        await #expect(throws: ProjectError.duplicateTarget("duplicate target 'MyApp'")) {
            try await generator().generate(spec: spec, at: url)
        }
    }
    
    @Test("rejects product referencing missing target")
    func missingProductTarget() async {
        let spec = ProjectSpec(
            name: "MyApp",
            products: [.init(name: "MyApp", type: .library, targets: ["Missing"])],
            targets: [.init(name: "MyApp", type: .target)]
        )
        let url = URL(fileURLWithPath: "/test/Missing")
        await #expect(throws: ProjectError.missingTarget("product 'MyApp' references unknown target 'Missing'")) {
            try await generator().generate(spec: spec, at: url)
        }
    }
    
    @Test("rejects product referencing test target")
    func productReferencesTestTarget() async {
        let spec = ProjectSpec(
            name: "MyApp",
            products: [.init(name: "MyApp", type: .library, targets: ["MyAppTests"])],
            targets: [
                .init(name: "MyApp", type: .target),
                .init(name: "MyAppTests", type: .testTarget)
            ]
        )
        let url = URL(fileURLWithPath: "/test/BadProd")
        await #expect(throws: ProjectError.invalidProduct("product 'MyApp' references test target 'MyAppTests'")) {
            try await generator().generate(spec: spec, at: url)
        }
    }
    
    @Test("rejects library product referencing executable target")
    func libraryProductReferencesExecutableTarget() async {
        let spec = ProjectSpec(
            name: "MyApp",
            products: [.init(name: "MyApp", type: .library, targets: ["MyTool"])],
            targets: [.init(name: "MyTool", type: .executableTarget)]
        )
        let url = URL(fileURLWithPath: "/test/BadProdType")
        await #expect(throws: ProjectError.invalidProduct("product 'MyApp' is a library but references executable target 'MyTool'")) {
            try await generator().generate(spec: spec, at: url)
        }
    }
    
    @Test("rejects executable product referencing regular target")
    func executableProductReferencesRegularTarget() async {
        let spec = ProjectSpec(
            name: "MyApp",
            products: [.init(name: "MyApp", type: .executable, targets: ["MyLib"])],
            targets: [.init(name: "MyLib", type: .target)]
        )
        let url = URL(fileURLWithPath: "/test/BadProdType2")
        await #expect(throws: ProjectError.invalidProduct("product 'MyApp' is an executable but references non-executable target 'MyLib'")) {
            try await generator().generate(spec: spec, at: url)
        }
    }
    
    @Test("rejects non-test target depending on test target")
    func nonTestTargetDependsOnTestTarget() async {
        let spec = ProjectSpec(
            name: "MyApp",
            targets: [
                .init(name: "MyApp", type: .target, dependencies: [.byName("MyAppTests")]),
                .init(name: "MyAppTests", type: .testTarget)
            ]
        )
        let url = URL(fileURLWithPath: "/test/BadDep")
        await #expect(throws: ProjectError.invalidProduct("target 'MyApp' cannot depend on test target 'MyAppTests'")) {
            try await generator().generate(spec: spec, at: url)
        }
    }
    
    @Test("rejects duplicate products")
    func duplicateProducts() async {
        let spec = ProjectSpec(
            name: "MyApp",
            products: [
                .init(name: "MyApp", type: .library, targets: ["MyApp"]),
                .init(name: "MyApp", type: .library, targets: ["MyApp"])
            ],
            targets: [.init(name: "MyApp", type: .target)]
        )
        let url = URL(fileURLWithPath: "/test/DupProd")
        await #expect(throws: ProjectError.duplicateProduct("duplicate product 'MyApp'")) {
            try await generator().generate(spec: spec, at: url)
        }
    }
    
    @Test("rejects duplicate dependencies")
    func duplicateDependencies() async {
        let spec = ProjectSpec(
            name: "MyApp",
            dependencies: [
                .init(url: "https://github.com/swiftanvil/anvil-network", requirement: .from("1.0.0")),
                .init(url: "https://github.com/swiftanvil/anvil-network", requirement: .from("2.0.0"))
            ]
        )
        let url = URL(fileURLWithPath: "/test/DupDep")
        await #expect(throws: ProjectError.duplicateDependency("duplicate dependency 'https://github.com/swiftanvil/anvil-network'")) {
            try await generator().generate(spec: spec, at: url)
        }
    }
    
    @Test("rejects byName dependency on missing target")
    func missingByNameDependency() async {
        let spec = ProjectSpec(
            name: "MyApp",
            targets: [
                .init(name: "MyApp", type: .target, dependencies: [.byName("Missing")])
            ]
        )
        let url = URL(fileURLWithPath: "/test/MissingDep")
        await #expect(throws: ProjectError.missingTarget("target 'MyApp' depends on unknown target 'Missing'")) {
            try await generator().generate(spec: spec, at: url)
        }
    }
    
    @Test("rejects product dependency on undeclared package")
    func missingPackageDependency() async {
        let spec = ProjectSpec(
            name: "MyApp",
            targets: [
                .init(name: "MyApp", type: .target, dependencies: [.product("AnvilNetwork", package: "anvil-network")])
            ]
        )
        let url = URL(fileURLWithPath: "/test/MissingPkg")
        await #expect(throws: ProjectError.missingDependency("target 'MyApp' depends on undeclared package 'anvil-network'")) {
            try await generator().generate(spec: spec, at: url)
        }
    }
    
    @Test("rejects unknown template")
    func unknownTemplate() async {
        let spec = ProjectSpec(
            name: "MyApp",
            targets: [.init(name: "MyApp", type: .target, sources: ["nonexistent"])]
        )
        let url = URL(fileURLWithPath: "/test/BadTemplate")
        await #expect(throws: ProjectError.unknownTemplate("unknown template 'nonexistent' in target 'MyApp'")) {
            try await generator().generate(spec: spec, at: url)
        }
    }
}

// MARK: - Generation Tests

@Suite("Generation")
struct GenerationTests {
    let fs = InMemoryFileSystem()
    
    func generator() -> ProjectGenerator {
        ProjectGenerator(fileSystem: fs)
    }
    
    @Test("generates Package.swift for minimal library")
    func minimalLibrary() async throws {
        let spec = ProjectSpec(
            name: "MyLib",
            products: [.init(name: "MyLib", type: .library, targets: ["MyLib"])],
            targets: [.init(name: "MyLib", type: .target, sources: ["library"])]
        )
        let url = URL(fileURLWithPath: "/test/MyLib")
        try await generator().generate(spec: spec, at: url)
        
        let packageSwift = await fs.content(at: url.appendingPathComponent("Package.swift"))!
        #expect(packageSwift.contains("name: \"MyLib\""))
        #expect(packageSwift.contains(".library(name: \"MyLib\", targets: [\"MyLib\"])"))
        #expect(packageSwift.contains(".target(name: \"MyLib\")"))
    }
    
    @Test("generates Package.swift with platforms")
    func withPlatforms() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            platforms: [.iOS(.v16), .macOS(.v14)],
            targets: [.init(name: "MyApp", type: .target)]
        )
        let url = URL(fileURLWithPath: "/test/MyApp")
        try await generator().generate(spec: spec, at: url)
        
        let packageSwift = await fs.content(at: url.appendingPathComponent("Package.swift"))!
        #expect(packageSwift.contains(".iOS(.v16)"))
        #expect(packageSwift.contains(".macOS(.v14)"))
    }
    
    @Test("generates Package.swift with dependencies")
    func withDependencies() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            dependencies: [
                .init(url: "https://github.com/swiftanvil/anvil-network", requirement: .from("1.0.0"))
            ],
            targets: [
                .init(name: "MyApp", type: .target, dependencies: [.product("AnvilNetwork", package: "anvil-network")])
            ]
        )
        let url = URL(fileURLWithPath: "/test/MyApp")
        try await generator().generate(spec: spec, at: url)
        
        let packageSwift = await fs.content(at: url.appendingPathComponent("Package.swift"))!
        #expect(packageSwift.contains(".package(url: \"https://github.com/swiftanvil/anvil-network\", from: \"1.0.0\")"))
        #expect(packageSwift.contains(".product(name: \"AnvilNetwork\", package: \"anvil-network\")"))
    }
    
    @Test("generates executable target")
    func executableTarget() async throws {
        let spec = ProjectSpec(
            name: "MyTool",
            products: [.init(name: "MyTool", type: .executable, targets: ["MyTool"])],
            targets: [.init(name: "MyTool", type: .executableTarget, sources: ["executable"])]
        )
        let url = URL(fileURLWithPath: "/test/MyTool")
        try await generator().generate(spec: spec, at: url)
        
        let packageSwift = await fs.content(at: url.appendingPathComponent("Package.swift"))!
        #expect(packageSwift.contains(".executable(name: \"MyTool\", targets: [\"MyTool\"])"))
        #expect(packageSwift.contains(".executableTarget(name: \"MyTool\")"))
        
        let sourceFile = await fs.content(at: url.appendingPathComponent("Sources/MyTool/executable.swift"))!
        #expect(sourceFile.contains("Hello, MyTool!"))
    }
    
    @Test("generates test target in Tests directory")
    func testTargetDirectory() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            targets: [
                .init(name: "MyApp", type: .target),
                .init(name: "MyAppTests", type: .testTarget, sources: ["test"])
            ]
        )
        let url = URL(fileURLWithPath: "/test/MyApp")
        try await generator().generate(spec: spec, at: url)
        
        #expect(await fs.directoryExists(at: url.appendingPathComponent("Tests/MyAppTests")))
        let testFile = await fs.content(at: url.appendingPathComponent("Tests/MyAppTests/test.swift"))!
        #expect(testFile.contains("@Test"))
    }
    
    @Test("generates README")
    func readmeGenerated() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            targets: [.init(name: "MyApp", type: .target)],
            includeReadme: true
        )
        let url = URL(fileURLWithPath: "/test/MyApp")
        try await generator().generate(spec: spec, at: url)
        
        let readme = await fs.content(at: url.appendingPathComponent("README.md"))!
        #expect(readme.contains("# MyApp"))
    }
    
    @Test("generates gitignore")
    func gitignoreGenerated() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            targets: [.init(name: "MyApp", type: .target)],
            includeGitignore: true
        )
        let url = URL(fileURLWithPath: "/test/MyApp")
        try await generator().generate(spec: spec, at: url)
        
        let gitignore = await fs.content(at: url.appendingPathComponent(".gitignore"))!
        #expect(gitignore.contains(".build/"))
    }
    
    @Test("skips README when disabled")
    func skipReadme() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            targets: [.init(name: "MyApp", type: .target)],
            includeReadme: false
        )
        let url = URL(fileURLWithPath: "/test/MyApp")
        try await generator().generate(spec: spec, at: url)
        
        #expect(await !fs.fileExists(at: url.appendingPathComponent("README.md")))
    }
    
    @Test("generates source file from template")
    func sourceFileFromTemplate() async throws {
        let spec = ProjectSpec(
            name: "MyLib",
            targets: [.init(name: "MyLib", type: .target, sources: ["library"])]
        )
        let url = URL(fileURLWithPath: "/test/MyLib")
        try await generator().generate(spec: spec, at: url)
        
        let source = await fs.content(at: url.appendingPathComponent("Sources/MyLib/library.swift"))!
        #expect(source.contains("public struct MyLib"))
    }
    
    @Test("sanitizes hyphens in Swift identifiers")
    func sanitizesHyphensInIdentifiers() async throws {
        let spec = ProjectSpec(
            name: "My-Lib",
            targets: [.init(name: "My-Lib", type: .target, sources: ["library"])]
        )
        let url = URL(fileURLWithPath: "/test/My-Lib")
        try await generator().generate(spec: spec, at: url)
        
        let source = await fs.content(at: url.appendingPathComponent("Sources/My-Lib/library.swift"))!
        #expect(source.contains("public struct My_Lib"))
        #expect(!source.contains("public struct My-Lib"))
    }
    
    @Test("escapes strings in Package.swift")
    func stringEscaping() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            dependencies: [
                .init(url: "https://example.com/path\"quote", requirement: .from("1.0\"beta"))
            ],
            targets: [.init(name: "MyApp", type: .target)]
        )
        let url = URL(fileURLWithPath: "/test/MyApp")
        try await generator().generate(spec: spec, at: url)
        
        let packageSwift = await fs.content(at: url.appendingPathComponent("Package.swift"))!
        // The escaped quotes should appear as \\\" in the file content
        #expect(packageSwift.contains("https://example.com/path\\\"quote"))
    }
}

// MARK: - Rollback Tests

@Suite("Rollback")
struct RollbackTests {
    let fs = InMemoryFileSystem()
    
    func generator() -> ProjectGenerator {
        ProjectGenerator(fileSystem: fs)
    }
    
    @Test("rolls back on validation failure")
    func rollbackOnValidation() async {
        let spec = ProjectSpec(name: "")
        let url = URL(fileURLWithPath: "/test/Bad")
        
        await #expect(throws: ProjectError.invalidName("name cannot be empty")) {
            try await generator().generate(spec: spec, at: url)
        }
        
        #expect(await !fs.exists(at: url))
    }
    
    @Test("rolls back on unknown template")
    func rollbackOnUnknownTemplate() async {
        let spec = ProjectSpec(
            name: "MyApp",
            targets: [.init(name: "MyApp", type: .target, sources: ["bad"])]
        )
        let url = URL(fileURLWithPath: "/test/Bad")
        
        await #expect(throws: ProjectError.unknownTemplate("unknown template 'bad' in target 'MyApp'")) {
            try await generator().generate(spec: spec, at: url)
        }
        
        #expect(await !fs.exists(at: url))
    }
    
    @Test("preserves pre-existing empty directory on failure")
    func preservesEmptyDirectory() async throws {
        let url = URL(fileURLWithPath: "/test/Existing")
        try await fs.createDirectory(at: url)
        
        let spec = ProjectSpec(name: "")
        await #expect(throws: ProjectError.invalidName("name cannot be empty")) {
            try await generator().generate(spec: spec, at: url)
        }
        
        // The empty directory should still exist
        #expect(await fs.directoryExists(at: url))
    }
}

// MARK: - Edge Case Tests

@Suite("EdgeCases")
struct EdgeCaseTests {
    let fs = InMemoryFileSystem()
    
    func generator() -> ProjectGenerator {
        ProjectGenerator(fileSystem: fs)
    }
    
    @Test("generates with no platforms")
    func noPlatforms() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            platforms: [],
            targets: [.init(name: "MyApp", type: .target)]
        )
        let url = URL(fileURLWithPath: "/test/NoPlatform")
        try await generator().generate(spec: spec, at: url)
        
        let packageSwift = await fs.content(at: url.appendingPathComponent("Package.swift"))!
        #expect(!packageSwift.contains("platforms:"))
    }
    
    @Test("generates with no dependencies")
    func noDependencies() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            targets: [.init(name: "MyApp", type: .target)]
        )
        let url = URL(fileURLWithPath: "/test/NoDeps")
        try await generator().generate(spec: spec, at: url)
        
        let packageSwift = await fs.content(at: url.appendingPathComponent("Package.swift"))!
        #expect(packageSwift.contains("dependencies: []"))
    }
    
    @Test("generates with no products")
    func noProducts() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            targets: [.init(name: "MyApp", type: .target)]
        )
        let url = URL(fileURLWithPath: "/test/NoProducts")
        try await generator().generate(spec: spec, at: url)
        
        let packageSwift = await fs.content(at: url.appendingPathComponent("Package.swift"))!
        #expect(packageSwift.contains("products: []"))
    }
    
    @Test("generates with no targets")
    func noTargets() async throws {
        let spec = ProjectSpec(name: "MyApp")
        let url = URL(fileURLWithPath: "/test/NoTargets")
        try await generator().generate(spec: spec, at: url)
        
        let packageSwift = await fs.content(at: url.appendingPathComponent("Package.swift"))!
        #expect(packageSwift.contains("targets: []"))
    }
    
    @Test("generates with multiple source templates")
    func multipleSources() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            targets: [.init(name: "MyApp", type: .target, sources: ["library", "executable"])]
        )
        let url = URL(fileURLWithPath: "/test/Multi")
        try await generator().generate(spec: spec, at: url)
        
        #expect(await fs.fileExists(at: url.appendingPathComponent("Sources/MyApp/library.swift")))
        #expect(await fs.fileExists(at: url.appendingPathComponent("Sources/MyApp/executable.swift")))
    }
    
    @Test("generates dependency with exact version")
    func exactVersion() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            dependencies: [
                .init(url: "https://github.com/swiftanvil/anvil-network", requirement: .exact("1.2.3"))
            ],
            targets: [.init(name: "MyApp", type: .target)]
        )
        let url = URL(fileURLWithPath: "/test/Exact")
        try await generator().generate(spec: spec, at: url)
        
        let packageSwift = await fs.content(at: url.appendingPathComponent("Package.swift"))!
        #expect(packageSwift.contains("exact: \"1.2.3\""))
    }
    
    @Test("generates dependency with branch")
    func branchDependency() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            dependencies: [
                .init(url: "https://github.com/swiftanvil/anvil-network", requirement: .branch("main"))
            ],
            targets: [.init(name: "MyApp", type: .target)]
        )
        let url = URL(fileURLWithPath: "/test/Branch")
        try await generator().generate(spec: spec, at: url)
        
        let packageSwift = await fs.content(at: url.appendingPathComponent("Package.swift"))!
        #expect(packageSwift.contains("branch: \"main\""))
    }
    
    @Test("generates dependency with revision")
    func revisionDependency() async throws {
        let spec = ProjectSpec(
            name: "MyApp",
            dependencies: [
                .init(url: "https://github.com/swiftanvil/anvil-network", requirement: .revision("abc123"))
            ],
            targets: [.init(name: "MyApp", type: .target)]
        )
        let url = URL(fileURLWithPath: "/test/Rev")
        try await generator().generate(spec: spec, at: url)
        
        let packageSwift = await fs.content(at: url.appendingPathComponent("Package.swift"))!
        #expect(packageSwift.contains("revision: \"abc123\""))
    }
}
