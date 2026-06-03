import Foundation

/// A supported platform with a version.
public enum Platform: Sendable {
    case iOS(IOSSupportedVersion)
    case macOS(MacOSSupportedVersion)
    case tvOS(TVOSSupportedVersion)
    case watchOS(WatchOSSupportedVersion)
    case visionOS(VisionOSSupportedVersion)
}

public enum IOSSupportedVersion: Sendable { case v16, v17, v18 }
public enum MacOSSupportedVersion: Sendable { case v13, v14, v15 }
public enum TVOSSupportedVersion: Sendable { case v16, v17, v18 }
public enum WatchOSSupportedVersion: Sendable { case v9, v10, v11 }
public enum VisionOSSupportedVersion: Sendable { case v1, v2 }

extension Platform {
    /// The Swift Package Manager platform name (e.g. "iOS", "macOS").
    var platformName: String {
        switch self {
        case .iOS: return "iOS"
        case .macOS: return "macOS"
        case .tvOS: return "tvOS"
        case .watchOS: return "watchOS"
        case .visionOS: return "visionOS"
        }
    }
    
    /// The version number for Package.swift (e.g. 16, 13).
    var versionNumber: Int {
        switch self {
        case .iOS(let v): return v.rawValue
        case .macOS(let v): return v.rawValue
        case .tvOS(let v): return v.rawValue
        case .watchOS(let v): return v.rawValue
        case .visionOS(let v): return v.rawValue
        }
    }
}

extension IOSSupportedVersion {
    var rawValue: Int {
        switch self {
        case .v16: return 16
        case .v17: return 17
        case .v18: return 18
        }
    }
}

extension MacOSSupportedVersion {
    var rawValue: Int {
        switch self {
        case .v13: return 13
        case .v14: return 14
        case .v15: return 15
        }
    }
}

extension TVOSSupportedVersion {
    var rawValue: Int {
        switch self {
        case .v16: return 16
        case .v17: return 17
        case .v18: return 18
        }
    }
}

extension WatchOSSupportedVersion {
    var rawValue: Int {
        switch self {
        case .v9: return 9
        case .v10: return 10
        case .v11: return 11
        }
    }
}

extension VisionOSSupportedVersion {
    var rawValue: Int {
        switch self {
        case .v1: return 1
        case .v2: return 2
        }
    }
}
