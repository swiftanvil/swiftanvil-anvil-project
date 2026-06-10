// AnvilProject — Swift Project Scaffolding Tool
// Host-agnostic, LLM-era project infrastructure for Apple platforms

import ArgumentParser
import Foundation

@main
struct AnvilProjectCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "anvil-project",
        abstract: "Swift project scaffolding with architectural enforcement",
        version: "0.1.0",
        subcommands: [
            CreateCommand.self,
            DoctorCommand.self,
            DocsCommand.self,
            ImmunityCommand.self
        ],
        defaultSubcommand: CreateCommand.self
    )
}
