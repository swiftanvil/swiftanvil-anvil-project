import Foundation
import Testing
@testable import AnvilProject

@Suite("ProjectGenerator")
struct ProjectGeneratorTests {
    private let fileManager = FileManager.default
    private let tempDir: URL = {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private func cleanup() {
        try? fileManager.removeItem(at: tempDir)
    }

    // MARK: - Generation Output

    @Test("generates project directory structure")
    func generatesDirectoryStructure() async throws {
        defer { cleanup() }
        let generator = ProjectGenerator()
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "TestApp",
            options: [:]
        )

        try await generator.generate(projectName: "TestApp", config: config, outputPath: tempDir.path)

        let projectDir = tempDir.appendingPathComponent("TestApp")
        #expect(fileManager.fileExists(atPath: projectDir.path))
        #expect(fileManager.fileExists(atPath: projectDir.appendingPathComponent("Sources/TestApp").path))
        #expect(fileManager.fileExists(atPath: projectDir.appendingPathComponent("Tests/TestAppTests").path))
        #expect(fileManager.fileExists(atPath: projectDir.appendingPathComponent("Tests/TestAppUITests").path))
        #expect(fileManager.fileExists(atPath: projectDir.appendingPathComponent("Documentation").path))
        #expect(fileManager.fileExists(atPath: projectDir.appendingPathComponent(".foundation").path))
    }

    @Test("generates Package.swift")
    func generatesPackageManifest() async throws {
        defer { cleanup() }
        let generator = ProjectGenerator()
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "TestApp",
            options: [:]
        )

        try await generator.generate(projectName: "TestApp", config: config, outputPath: tempDir.path)

        let manifestPath = tempDir.appendingPathComponent("TestApp/Package.swift")
        #expect(fileManager.fileExists(atPath: manifestPath.path))

        let content = try String(contentsOf: manifestPath, encoding: .utf8)
        #expect(content.contains("TestApp"))
        #expect(content.contains("swift-tools-version"))
    }

    @Test("throws when destination exists")
    func throwsWhenDestinationExists() async throws {
        defer { cleanup() }
        let generator = ProjectGenerator()
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "ExistingApp",
            options: [:]
        )

        // Create the directory first
        let existingDir = tempDir.appendingPathComponent("ExistingApp")
        try fileManager.createDirectory(at: existingDir, withIntermediateDirectories: true)

        await #expect(throws: GenerationError.self) {
            try await generator.generate(projectName: "ExistingApp", config: config, outputPath: tempDir.path)
        }
    }

    @Test("generates source files")
    func generatesSourceFiles() async throws {
        defer { cleanup() }
        let generator = ProjectGenerator()
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "TestApp",
            options: [:]
        )

        try await generator.generate(projectName: "TestApp", config: config, outputPath: tempDir.path)

        let sourcesDir = tempDir.appendingPathComponent("TestApp/Sources/TestApp")
        #expect(fileManager.fileExists(atPath: sourcesDir.appendingPathComponent("TestAppApp.swift").path))
        #expect(fileManager.fileExists(atPath: sourcesDir.appendingPathComponent("Views/ContentView.swift").path))
        #expect(fileManager.fileExists(atPath: sourcesDir.appendingPathComponent("ViewModels/AppViewModel.swift").path))
        #expect(fileManager.fileExists(atPath: sourcesDir.appendingPathComponent("Models/AppModel.swift").path))
        #expect(fileManager.fileExists(atPath: sourcesDir.appendingPathComponent("Services/NetworkService.swift").path))
    }

    @Test("generates unit tests when enabled")
    func generatesUnitTests() async throws {
        defer { cleanup() }
        let generator = ProjectGenerator()
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "TestApp",
            options: ["includeUnitTests": .bool(true)]
        )

        try await generator.generate(projectName: "TestApp", config: config, outputPath: tempDir.path)

        let testPath = tempDir.appendingPathComponent("TestApp/Tests/TestAppTests/TestAppTests.swift")
        #expect(fileManager.fileExists(atPath: testPath.path))
    }

    @Test("generates UI tests when enabled")
    func generatesUITests() async throws {
        defer { cleanup() }
        let generator = ProjectGenerator()
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "TestApp",
            options: ["includeUITests": .bool(true)]
        )

        try await generator.generate(projectName: "TestApp", config: config, outputPath: tempDir.path)

        let testPath = tempDir.appendingPathComponent("TestApp/Tests/TestAppUITests/TestAppUITests.swift")
        #expect(fileManager.fileExists(atPath: testPath.path))
    }

    @Test("generates accessibility helper when enabled")
    func generatesAccessibilityHelper() async throws {
        defer { cleanup() }
        let generator = ProjectGenerator()
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "TestApp",
            options: ["enableAccessibility": .bool(true)]
        )

        try await generator.generate(projectName: "TestApp", config: config, outputPath: tempDir.path)

        let helperPath = tempDir.appendingPathComponent("TestApp/Sources/TestApp/Utilities/AccessibilityHelper.swift")
        #expect(fileManager.fileExists(atPath: helperPath.path))
    }

    @Test("generates localization when enabled")
    func generatesLocalization() async throws {
        defer { cleanup() }
        let generator = ProjectGenerator()
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "TestApp",
            options: [
                "enableLocalization": .bool(true),
                "targetLanguages": .stringArray(["en", "ja"])
            ]
        )

        try await generator.generate(projectName: "TestApp", config: config, outputPath: tempDir.path)

        let stringsPath = tempDir.appendingPathComponent("TestApp/Sources/TestApp/Resources/Localizable.xcstrings")
        #expect(fileManager.fileExists(atPath: stringsPath.path))
    }

    @Test("generates CI workflow")
    func generatesCIWorkflow() async throws {
        defer { cleanup() }
        let generator = ProjectGenerator()
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "TestApp",
            options: [:]
        )

        try await generator.generate(projectName: "TestApp", config: config, outputPath: tempDir.path)

        let workflowPath = tempDir.appendingPathComponent("TestApp/.github/workflows/ci.yml")
        #expect(fileManager.fileExists(atPath: workflowPath.path))
    }

    @Test("generates AGENTS.md")
    func generatesAgentsMD() async throws {
        defer { cleanup() }
        let generator = ProjectGenerator()
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "TestApp",
            options: [:]
        )

        try await generator.generate(projectName: "TestApp", config: config, outputPath: tempDir.path)

        let agentsPath = tempDir.appendingPathComponent("TestApp/AGENTS.md")
        #expect(fileManager.fileExists(atPath: agentsPath.path))

        let content = try String(contentsOf: agentsPath, encoding: .utf8)
        #expect(content.contains("TestApp"))
    }

    @Test("generates immunity config when enabled")
    func generatesImmunityConfig() async throws {
        defer { cleanup() }
        let generator = ProjectGenerator()
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "TestApp",
            options: ["enableImmunity": .bool(true)]
        )

        try await generator.generate(projectName: "TestApp", config: config, outputPath: tempDir.path)

        let immunityPath = tempDir.appendingPathComponent("TestApp/.foundation/immunity.json")
        #expect(fileManager.fileExists(atPath: immunityPath.path))
    }

    @Test("generates git hooks")
    func generatesGitHooks() async throws {
        defer { cleanup() }
        let generator = ProjectGenerator()
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "TestApp",
            options: [:]
        )

        try await generator.generate(projectName: "TestApp", config: config, outputPath: tempDir.path)

        let hookPath = tempDir.appendingPathComponent("TestApp/.git/hooks/pre-commit")
        #expect(fileManager.fileExists(atPath: hookPath.path))
    }

    @Test("generates documentation registry")
    func generatesDocumentationRegistry() async throws {
        defer { cleanup() }
        let generator = ProjectGenerator()
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "TestApp",
            options: [:]
        )

        try await generator.generate(projectName: "TestApp", config: config, outputPath: tempDir.path)

        let registryPath = tempDir.appendingPathComponent("TestApp/Documentation/Registry/index.yml")
        #expect(fileManager.fileExists(atPath: registryPath.path))
    }

    @Test("Package.swift includes correct platform versions")
    func packagePlatformVersions() async throws {
        defer { cleanup() }
        let generator = ProjectGenerator()
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "TestApp",
            options: ["minimumOSVersion": .string("18.0")]
        )

        try await generator.generate(projectName: "TestApp", config: config, outputPath: tempDir.path)

        let manifestPath = tempDir.appendingPathComponent("TestApp/Package.swift")
        let content = try String(contentsOf: manifestPath, encoding: .utf8)
        #expect(content.contains("iOS(.v18_0)"))
    }
}
