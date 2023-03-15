import Foundation
import UIKit

public enum AppEnv {
    public enum Env: String {
        case debug
        case prod
        case testFlight
    }

    // This is private because the use of 'appConfiguration' is preferred.
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"

    // This can be used to add debug statements.
    public static var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

    public static var env: Env {
        if isDebug {
            return .debug
        } else if isTestFlight {
            return .testFlight
        } else {
            return .prod
        }
    }
}
