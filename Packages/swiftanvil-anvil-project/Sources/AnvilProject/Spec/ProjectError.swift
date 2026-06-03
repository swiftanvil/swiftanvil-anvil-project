import Foundation

/// Errors that can occur during project generation.
public enum ProjectError: Error, Sendable, Equatable {
    case invalidName(String)
    case directoryNotEmpty(String)
    case duplicateTarget(String)
    case duplicateProduct(String)
    case duplicateDependency(String)
    case missingTarget(String)
    case missingDependency(String)
    case invalidProduct(String)
    case unknownTemplate(String)
    case fileSystemError(String)
    case generationFailed(String)
}
