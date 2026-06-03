import Foundation

/// Abstracts file system operations for testability.
public protocol FileSystem: Sendable {
    func fileExists(at path: URL) -> Bool
    func directoryExists(at path: URL) -> Bool
    func contentsOfDirectory(at path: URL) throws -> [String]
    func createDirectory(at path: URL) throws
    func write(_ content: String, to path: URL) throws
    func removeItem(at path: URL) throws
}

/// File system implementation using FileManager.
public struct FileManagerFileSystem: FileSystem {
    public init() {}
    
    public func fileExists(at path: URL) -> Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: path.path, isDirectory: &isDir) && !isDir.boolValue
    }
    
    public func directoryExists(at path: URL) -> Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: path.path, isDirectory: &isDir) && isDir.boolValue
    }
    
    public func contentsOfDirectory(at path: URL) throws -> [String] {
        try FileManager.default.contentsOfDirectory(atPath: path.path)
    }
    
    public func createDirectory(at path: URL) throws {
        try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
    }
    
    public func write(_ content: String, to path: URL) throws {
        let tmp = path.appendingPathExtension("tmp")
        try content.write(to: tmp, atomically: false, encoding: .utf8)
        if fileExists(at: path) {
            _ = try FileManager.default.replaceItemAt(path, withItemAt: tmp)
        } else {
            try FileManager.default.moveItem(at: tmp, to: path)
        }
    }
    
    public func removeItem(at path: URL) throws {
        try FileManager.default.removeItem(at: path)
    }
}

/// Reference-type storage for InMemoryFileSystem to avoid mutating protocol requirements.
private final class InMemoryStorage: @unchecked Sendable {
    private let lock = NSLock()
    var files: [String: String] = [:]
    var directories: Set<String> = []
    
    func withLock<T>(_ block: () throws -> T) throws -> T {
        lock.lock()
        defer { lock.unlock() }
        return try block()
    }
    
    func withLock<T>(_ block: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return block()
    }
}

/// In-memory file system for testing.
public struct InMemoryFileSystem: FileSystem {
    private let storage = InMemoryStorage()
    
    public init() {}
    
    public func fileExists(at path: URL) -> Bool {
        storage.withLock { storage.files[path.path] != nil }
    }
    
    public func directoryExists(at path: URL) -> Bool {
        storage.withLock { storage.directories.contains(path.path) }
    }
    
    public func contentsOfDirectory(at path: URL) throws -> [String] {
        try storage.withLock {
            guard storage.directories.contains(path.path) else {
                throw ProjectError.fileSystemError("Directory does not exist: \(path.path)")
            }
            let prefix = path.path + "/"
            var names = Set<String>()
            for filePath in storage.files.keys where filePath.hasPrefix(prefix) {
                let remainder = String(filePath.dropFirst(prefix.count))
                if let slashIndex = remainder.firstIndex(of: "/") {
                    names.insert(String(remainder[..<slashIndex]))
                } else {
                    names.insert(remainder)
                }
            }
            for dirPath in storage.directories where dirPath.hasPrefix(prefix) && dirPath != path.path {
                let remainder = String(dirPath.dropFirst(prefix.count))
                if !remainder.contains("/") {
                    names.insert(remainder)
                }
            }
            return Array(names)
        }
    }
    
    public func createDirectory(at path: URL) throws {
        storage.withLock { storage.directories.insert(path.path) }
    }
    
    public func write(_ content: String, to path: URL) throws {
        storage.withLock { storage.files[path.path] = content }
    }
    
    public func removeItem(at path: URL) throws {
        storage.withLock {
            storage.files.removeValue(forKey: path.path)
            storage.directories.remove(path.path)
            let prefix = path.path + "/"
            storage.files.keys.filter { $0.hasPrefix(prefix) }.forEach { storage.files.removeValue(forKey: $0) }
            storage.directories.filter { $0.hasPrefix(prefix) }.forEach { storage.directories.remove($0) }
        }
    }
    
    /// Returns the content of a file for test verification.
    public func content(at path: URL) -> String? {
        storage.withLock { storage.files[path.path] }
    }
    
    /// Returns true if a file or directory exists at the path.
    public func exists(at path: URL) -> Bool {
        storage.withLock { storage.files[path.path] != nil || storage.directories.contains(path.path) }
    }
}
