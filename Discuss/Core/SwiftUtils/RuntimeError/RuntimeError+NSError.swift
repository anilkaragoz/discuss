import Foundation
import Logging

extension NSError {
    func report(attributes: [String: Any]? = nil) {
        var attrs: [String: Any] = ["id": domain, "code": code]

        if let attributes = attributes {
            attrs.merge(attributes) { current, _ in current }
        }

        if AppEnv.isDebug { fatalError() }

        _ = NSError(domain: domain, code: code, userInfo: attrs)
        
        // Report to crash tracking sdk
    }
}
