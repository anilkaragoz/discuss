import Foundation

struct User {
    let id: String

    init() {
        if let userId = UserProperties.userId {
            id = userId
        } else {
            let userId = UUID().uuidString
            UserProperties.userId = userId
            id = userId
        }
    }
}
