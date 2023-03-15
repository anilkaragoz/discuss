import Foundation

public enum UserDefaultsKey: String, Equatable, Codable {
    case userId
    case scenarios
    case firstSeenVersion
    case lastSeenVersion
    case firstSeenBuild
    case lastSeenBuild
    case firstLaunchDate
    case latestLaunchDate
    case lastUpdateDate
    case launchCount
    case shareCount
    case saveCount
    case lastRatingRequestBuild
    case lastRatingRequestDate
}

@propertyWrapper
public struct UserDefault<T> {
    let suiteName: String
    let key: UserDefaultsKey
    let defaultValue: T

    public init(_ key: UserDefaultsKey, defaultValue: T, suiteName: String) {
        self.suiteName = suiteName
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            let userDefault = UserDefaults(suiteName: suiteName)
            return userDefault?.object(forKey: key.rawValue) as? T ?? defaultValue
        }
        set {
            let userDefault = UserDefaults(suiteName: suiteName)
            if let optional = newValue as? AnyOptional, optional.isNil {
                userDefault?.removeObject(forKey: key.rawValue)
            } else {
                userDefault?.set(newValue, forKey: key.rawValue)
                userDefault?.synchronize()
            }
        }
    }
}

public protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}
