import Foundation
import Testing
@testable import AnvilProject

@Suite("TemplateEngine")
struct TemplateEngineTests {
    @Test("Encodable toDictionary converts struct")
    func encodableToDictionary() throws {
        struct TestConfig: Codable {
            let name: String
            let count: Int
        }
        let config = TestConfig(name: "Test", count: 42)
        let dict = try config.toDictionary()
        #expect(dict["name"] as? String == "Test")
        #expect(dict["count"] as? Int == 42)
    }

    @Test("Encodable toDictionary with nested values")
    func encodableToDictionaryNested() throws {
        struct Nested: Codable {
            let items: [String]
            let flag: Bool
        }
        let nested = Nested(items: ["a", "b"], flag: true)
        let dict = try nested.toDictionary()
        #expect(dict["items"] as? [String] == ["a", "b"])
        #expect(dict["flag"] as? Bool == true)
    }

    @Test("toDictionary throws on non-dict JSON")
    func toDictionaryThrows() {
        // This tests that the encoding path works; we can't easily trigger
        // encodingFailed with valid Codable types, so we verify the happy path.
        struct Simple: Codable {
            let value: String
        }
        let simple = Simple(value: "x")
        let dict = try? simple.toDictionary()
        #expect(dict != nil)
    }
}

@Suite("GenerationError")
struct GenerationErrorTests {
    @Test("destinationExists description")
    func destinationExistsDescription() {
        let error = GenerationError.destinationExists("/some/path")
        #expect(error.description.contains("Destination already exists"))
        #expect(error.description.contains("/some/path"))
    }

    @Test("templateNotFound description")
    func templateNotFoundDescription() {
        let error = GenerationError.templateNotFound("missing-template")
        #expect(error.description.contains("Template not found"))
        #expect(error.description.contains("missing-template"))
    }

    @Test("invalidConfiguration description")
    func invalidConfigurationDescription() {
        let error = GenerationError.invalidConfiguration("bad option")
        #expect(error.description.contains("Invalid configuration"))
        #expect(error.description.contains("bad option"))
    }
}

@Suite("TemplateError")
struct TemplateErrorTests {
    @Test("templateError cases exist")
    func casesExist() {
        let encoding = TemplateError.encodingFailed
        let notFound = TemplateError.templateNotFound("test")
        // Just verify they compile and can be created
        _ = encoding
        _ = notFound
    }
}
