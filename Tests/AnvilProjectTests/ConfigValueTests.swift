import Foundation
import Testing
@testable import AnvilProject

@Suite("ConfigValue")
struct ConfigValueTests {
    @Test("string value extraction")
    func stringValue() {
        let value = ConfigValue.string("hello")
        #expect(value.stringValue == "hello")
        #expect(value.boolValue == nil)
        #expect(value.intValue == nil)
        #expect(value.stringArray == nil)
    }

    @Test("bool value extraction")
    func boolValue() {
        let value = ConfigValue.bool(true)
        #expect(value.boolValue == true)
        #expect(value.stringValue == nil)
        #expect(value.intValue == nil)
        #expect(value.stringArray == nil)
    }

    @Test("int value extraction")
    func intValue() {
        let value = ConfigValue.int(42)
        #expect(value.intValue == 42)
        #expect(value.stringValue == nil)
        #expect(value.boolValue == nil)
        #expect(value.stringArray == nil)
    }

    @Test("stringArray value extraction")
    func stringArrayValue() {
        let value = ConfigValue.stringArray(["a", "b"])
        #expect(value.stringArray == ["a", "b"])
        #expect(value.stringValue == nil)
        #expect(value.boolValue == nil)
        #expect(value.intValue == nil)
    }

    @Test("Codable round-trip for string")
    func codableRoundTripString() throws {
        let original = ConfigValue.string("test")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: data)
        #expect(decoded.stringValue == "test")
    }

    @Test("Codable round-trip for bool")
    func codableRoundTripBool() throws {
        let original = ConfigValue.bool(false)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: data)
        #expect(decoded.boolValue == false)
    }

    @Test("Codable round-trip for int")
    func codableRoundTripInt() throws {
        let original = ConfigValue.int(99)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: data)
        #expect(decoded.intValue == 99)
    }

    @Test("Codable round-trip for stringArray")
    func codableRoundTripStringArray() throws {
        let original = ConfigValue.stringArray(["x", "y", "z"])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConfigValue.self, from: data)
        #expect(decoded.stringArray == ["x", "y", "z"])
    }

    @Test("ConfigValue is Sendable")
    func sendable() {
        let value = ConfigValue.string("sendable")
        _ = value as Sendable
    }
}

@Suite("ProjectConfig Extended")
struct ProjectConfigExtendedTests {
    @Test("default minimumOSVersion")
    func defaultMinimumOSVersion() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: [:]
        )
        #expect(config.minimumOSVersion == nil)
    }

    @Test("custom minimumOSVersion")
    func customMinimumOSVersion() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: ["minimumOSVersion": .string("18.0")]
        )
        #expect(config.minimumOSVersion == "18.0")
    }

    @Test("default useSwiftUI")
    func defaultUseSwiftUI() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: [:]
        )
        #expect(config.useSwiftUI == true)
    }

    @Test("disabled useSwiftUI")
    func disabledUseSwiftUI() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: ["useSwiftUI": .bool(false)]
        )
        #expect(config.useSwiftUI == false)
    }

    @Test("default useCoreData")
    func defaultUseCoreData() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: [:]
        )
        #expect(config.useCoreData == false)
    }

    @Test("enabled useCoreData")
    func enabledUseCoreData() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: ["useCoreData": .bool(true)]
        )
        #expect(config.useCoreData == true)
    }

    @Test("default useCloudKit")
    func defaultUseCloudKit() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: [:]
        )
        #expect(config.useCloudKit == false)
    }

    @Test("default targetLanguages")
    func defaultTargetLanguages() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: [:]
        )
        #expect(config.targetLanguages == ["en"])
    }

    @Test("custom targetLanguages")
    func customTargetLanguages() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: ["targetLanguages": .stringArray(["en", "es", "fr"])]
        )
        #expect(config.targetLanguages == ["en", "es", "fr"])
    }

    @Test("default includeSnapshotTests")
    func defaultIncludeSnapshotTests() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: [:]
        )
        #expect(config.includeSnapshotTests == false)
    }

    @Test("default includePerformanceTests")
    func defaultIncludePerformanceTests() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: [:]
        )
        #expect(config.includePerformanceTests == false)
    }

    @Test("default ciProvider")
    func defaultCIProvider() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: [:]
        )
        #expect(config.ciProvider == "github-actions")
    }

    @Test("custom ciProvider")
    func customCIProvider() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: ["ciProvider": .string("gitlab-ci")]
        )
        #expect(config.ciProvider == "gitlab-ci")
    }

    @Test("default useSelfHostedRunners")
    func defaultUseSelfHostedRunners() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: [:]
        )
        #expect(config.useSelfHostedRunners == false)
    }

    @Test("default enableImmunity")
    func defaultEnableImmunity() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: [:]
        )
        #expect(config.enableImmunity == true)
    }

    @Test("ProjectConfig is Codable")
    func codable() throws {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: ["key": .string("value")]
        )
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(ProjectConfig.self, from: data)
        #expect(decoded.projectName == "Test")
        #expect(decoded.template == "ios-app")
    }

    @Test("ProjectConfig is Sendable")
    func sendable() {
        let config = ProjectConfig(
            template: "ios-app",
            projectName: "Test",
            options: [:]
        )
        _ = config as Sendable
    }
}
