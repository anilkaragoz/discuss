import Foundation
import UIKit

private let fallbackLanguage = "en"
private let fallbackBundlePath = Bundle.main.path(forResource: fallbackLanguage, ofType: "lproj")!
private let fallbackBundle = Bundle(path: fallbackBundlePath)!

extension String {
    var localized: String {
        let key = self
        let fallbackString = fallbackBundle.localizedString(forKey: key, value: key, table: nil)
        return Bundle.main.localizedString(forKey: key, value: fallbackString, table: nil)
    }

    var localizedIfExists: String? {
        let key = self
        let s = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
        if s == key {
            return nil
        }
        return s
    }

    var appleLocalized: String {
        let uikit = Bundle(for: UIButton.self)
        return uikit.localizedString(forKey: self, value: nil, table: nil)
    }
}
