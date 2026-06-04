import Foundation
import Testing
import ArgumentParser
@testable import AnvilProject

@Suite("CreateCommand")
struct CreateCommandTests {
    @Test("parses project name argument")
    func parsesProjectName() throws {
        let command = try CreateCommand.parse(["MyApp"])
        #expect(command.projectName == "MyApp")
    }

    @Test("parses template option")
    func parsesTemplateOption() throws {
        let command = try CreateCommand.parse(["MyApp", "--template", "swift-library"])
        #expect(command.projectName == "MyApp")
        #expect(command.template == "swift-library")
    }

    @Test("parses short template option")
    func parsesShortTemplateOption() throws {
        let command = try CreateCommand.parse(["MyApp", "-t", "macos-app"])
        #expect(command.template == "macos-app")
    }

    @Test("parses interactive flag")
    func parsesInteractiveFlag() throws {
        let command = try CreateCommand.parse(["MyApp", "--interactive"])
        #expect(command.interactive == true)
    }

    @Test("parses short interactive flag")
    func parsesShortInteractiveFlag() throws {
        let command = try CreateCommand.parse(["MyApp", "-i"])
        #expect(command.interactive == true)
    }

    @Test("parses output option")
    func parsesOutputOption() throws {
        let command = try CreateCommand.parse(["MyApp", "--output", "/tmp/projects"])
        #expect(command.output == "/tmp/projects")
    }

    @Test("parses short output option")
    func parsesShortOutputOption() throws {
        let command = try CreateCommand.parse(["MyApp", "-o", "/tmp/out"])
        #expect(command.output == "/tmp/out")
    }

    @Test("default template is nil")
    func defaultTemplateNil() throws {
        let command = try CreateCommand.parse(["MyApp"])
        #expect(command.template == nil)
    }

    @Test("default interactive is false")
    func defaultInteractiveFalse() throws {
        let command = try CreateCommand.parse(["MyApp"])
        #expect(command.interactive == false)
    }

    @Test("default output is nil")
    func defaultOutputNil() throws {
        let command = try CreateCommand.parse(["MyApp"])
        #expect(command.output == nil)
    }

    @Test("parses all options together")
    func parsesAllOptions() throws {
        let command = try CreateCommand.parse([
            "MyApp",
            "--template", "ios-app",
            "--interactive",
            "--output", "/tmp/out"
        ])
        #expect(command.projectName == "MyApp")
        #expect(command.template == "ios-app")
        #expect(command.interactive == true)
        #expect(command.output == "/tmp/out")
    }

    @Test("command configuration has correct name")
    func commandConfiguration() {
        #expect(CreateCommand.configuration.commandName == "create")
        #expect(CreateCommand.configuration.abstract.contains("Create"))
    }

    @Test("fails without project name")
    func failsWithoutProjectName() {
        #expect(throws: (any Error).self) {
            try CreateCommand.parse([])
        }
    }

    @Test("fails with unknown flag")
    func failsWithUnknownFlag() {
        #expect(throws: (any Error).self) {
            try CreateCommand.parse(["MyApp", "--unknown-flag"])
        }
    }
}
