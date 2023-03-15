import Foundation
import StoreKit

struct RatingController {
    struct Constant {
        static let minDaysInterval = 31
        static let minSave = 2
        static let minShare = 2
    }

    @discardableResult static func showRatingIfNeeded() -> Bool {
        if let askedVersion = UserProperties.lastRatingRequestBuild {
            if askedVersion == VersionInfo.version {
                return false
            }

            if UserProperties.saveCount < Constant.minSave && UserProperties.shareCount < Constant.minShare {
                return false
            }
            

            if let askedDate = UserProperties.lastRatingRequestDate,
               abs(askedDate.timeIntervalSinceNow) < 3600 * 24 * TimeInterval(Constant.minDaysInterval)
            {
                return false
            }
            show()
            return true
        } else {
            if UserProperties.saveCount < Constant.minSave && UserProperties.shareCount < Constant.minShare {
                return false
            }
            show()
            return true
        }
    }

    private static func show() {
        UserProperties.lastRatingRequestBuild = VersionInfo.version
        UserProperties.lastRatingRequestDate = Date()
        if let scene = UIApplication.shared.currentScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
