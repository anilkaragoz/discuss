import Foundation
import Logging

public struct RuntimeError {
    private static var logger = Logger(label: "❗️Runtime Error")

    public static func track(
        _ localId: String? = nil,
        message: String = "",
        attributes: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line, col: Int = #column
    ) {
        var id = runtimeIdFrom(file, function)
        if let localId = localId {
            id += ".\(localId)"
        }

        var desc = "line \(line) col \(col)"
        if message.isEmpty == false {
            desc += " – \(message)"
        }
        track(id, desc, attributes)
    }

    private static func track(_ identifier: String, _ message: String? = nil, _ attributes: [String: Any]? = nil) {
        logger.error("\(identifier)")

        var attrs: [String: Any] = attributes ?? [:]
        if let message = message {
            logger.error("\(message)")
            attrs["message"] = message
        }

        let error = NSError(domain: identifier, code: 0, userInfo: nil)
        error.report(attributes: attrs)
    }

    private static func runtimeIdFrom(_ file: String, _ function: String) -> String {
        let url = URL(fileURLWithPath: file)
        return "\(url.deletingPathExtension().lastPathComponent).\(function)"
    }

    // MARK: - Error

    public static func track(_ error: Error, _ message: String? = nil) {
        logger.error("\(error.localizedDescription)")
        if let message = message {
            logger.error("\(message)")
        }
        (error as NSError).report()
    }

    // MARK: - NSError

    public static func track(_ error: NSError, _ message: String? = nil) {
        logger.error("\(error.localizedDescription)")
        if let message = message {
            logger.error("\(message)")
        }
        error.report()
    }
}
