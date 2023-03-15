import Foundation
import UIKit

class UserProperties {
    @UserDefault(UserDefaultsKey.scenarios, defaultValue: Data([]), suiteName: Constants.appGroup)
    static var scenariosData: Data
    
    @UserDefault(UserDefaultsKey.userId, defaultValue: nil, suiteName: Constants.appGroup)
    static var userId: String?
    
    @UserDefault(UserDefaultsKey.firstSeenVersion, defaultValue: nil, suiteName: Constants.appGroup)
    static var firstSeenVersion: String?

    @UserDefault(UserDefaultsKey.lastSeenVersion, defaultValue: nil, suiteName: Constants.appGroup)
    static var lastSeenVersion: String?

    @UserDefault(UserDefaultsKey.firstSeenBuild, defaultValue: nil, suiteName: Constants.appGroup)
    static var firstSeenBuild: String?

    @UserDefault(UserDefaultsKey.lastSeenBuild, defaultValue: nil, suiteName: Constants.appGroup)
    static var lastSeenBuild: String?

    @UserDefault(UserDefaultsKey.lastUpdateDate, defaultValue: Date(), suiteName: Constants.appGroup)
    static var lastUpdateDate: Date

    @UserDefault(UserDefaultsKey.firstLaunchDate, defaultValue: Date(), suiteName: Constants.appGroup)
    static var firstLaunchDate: Date

    @UserDefault(UserDefaultsKey.latestLaunchDate, defaultValue: Date(), suiteName: Constants.appGroup)
    static var latestLaunchDate: Date

    @UserDefault(UserDefaultsKey.launchCount, defaultValue: 0, suiteName: Constants.appGroup)
    static var launchCount: Int

    @UserDefault(UserDefaultsKey.shareCount, defaultValue: 0, suiteName: Constants.appGroup)
    static var shareCount: Int

    @UserDefault(UserDefaultsKey.saveCount, defaultValue: 0, suiteName: Constants.appGroup)
    static var saveCount: Int

    @UserDefault(UserDefaultsKey.lastRatingRequestBuild, defaultValue: nil, suiteName: Constants.appGroup)
    static var lastRatingRequestBuild: String?

    @UserDefault(UserDefaultsKey.lastRatingRequestDate, defaultValue: nil, suiteName: Constants.appGroup)
    static var lastRatingRequestDate: Date?

    // MARK: - Launch

    static func launch() {
        if isFirstLaunch {
            logger.info("First launch")

            lastUpdateDate = Date()
            firstLaunchDate = Date()
            firstSeenVersion = VersionInfo.version
            firstSeenBuild = VersionInfo.build
        }

        if lastSeenVersion != VersionInfo.version {
            appUpdate()
        }
    }

    private static func appUpdate() {
        logger.info("App Update")

        lastUpdateDate = Date()
        lastSeenVersion = VersionInfo.version
        lastSeenBuild = VersionInfo.build
    }

    // MARK: - Launch Counts

    static var isFirstLaunch: Bool {
        launchCount <= 1
    }

    // MARK: - Counters

    static func incrementLaunchCount() {
        launchCount += 1
    }

    static func incrementShareCount() {
        shareCount  += 1
    }

    static func incrementSaveCount() {
        saveCount += 1
    }

    // MARK: - Init

    private init() {}
}
