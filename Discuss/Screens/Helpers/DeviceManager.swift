import Foundation
import UIKit

final class DeviceManager {
    var deviceDebug: String {
        let infos: [(String, String)] = [
            ("Version", VersionInfo.version),
            ("Build", VersionInfo.build),
            ("Env", AppEnv.env.rawValue),
            ("UserId", User().id),
            ("DeviceId", UIDevice.current.modelIdentifier),
            ("Language", Locale.current.language.languageCode?.identifier ?? "nil"),
            ("Region", Locale.current.language.region?.identifier ?? "nil"),
            ("Currency", Locale.current.currency?.identifier ?? "nil")
        ]
        return infos.map { $0 + ": " + $1 }.joined(separator: "\n")
    }
}

public enum VersionInfo {
    public static let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    public static let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    public static var buildInteger: Int {
        Int(build.replacingOccurrences(of: ".", with: "")) ?? 0
    }
}

public extension UIDevice {
    var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    var hasNotch: Bool {
        guard let window = UIApplication.shared.kWindow else { return false }
        if UIDevice.current.orientation.isPortrait {
            return window.safeAreaInsets.top >= 44
        } else {
            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
        }
    }
}
