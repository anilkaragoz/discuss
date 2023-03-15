import Logging
import SwiftUI

var logger = Logger(label: "Discuss")

@main
struct DiscussApp: App {
    init() {
        logger.logLevel = .debug
        
        // User Properties
        UserProperties.incrementLaunchCount()
        UserProperties.launch()
    }
    
    var body: some Scene {
        WindowGroup {
            ScenarioListView().preferredColorScheme(.light)
        }
    }
}
