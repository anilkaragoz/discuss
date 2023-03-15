import UIKit

struct Scenario: Codable, Identifiable, Equatable {
    static func ==(lhs: Scenario, rhs: Scenario) -> Bool {
        lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.messages.elementsEqual(rhs.messages)
            && lhs.me == rhs.me
            && lhs.recipient == rhs.recipient
            && lhs.palette == rhs.palette
            && lhs.timestamp == rhs.timestamp
    }
    
    enum Template: Codable {
        case iMessage, `default`
    }

    let id: UUID
    var name: String
    var messages: [Message]
    var me: Contact
    var recipient: Contact
    var palette: ConversationPalette
    var timestamp: Date
    var template: Template = .default

    init(id: UUID = UUID(), name: String, messages: [Message], me: Contact, recipient: Contact, palette: ConversationPalette, timestamp: Date, template: Template = .default) {
        self.id = id
        self.name = name
        self.messages = messages
        self.me = me
        self.recipient = recipient
        self.palette = palette
        self.timestamp = timestamp
        self.template = .iMessage
    }
}

struct Contact: Codable, Equatable {
    static func ==(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.image?.pngData() == rhs.image?.pngData()
    }

    let id: UUID
    @CodableImage var image: UIImage?
    var name: String

    init(id: UUID = UUID(), image: UIImage?, name: String) {
        self.id = id
        self.image = image
        self.name = name
    }
}

struct Message: Equatable, Codable {
    static func ==(lhs: Message, rhs: Message) -> Bool {
        return (lhs.id == rhs.id) && (lhs.text == rhs.text)
    }

    init(id: UUID = UUID(), author: Contact, text: String, timestamp: Date) {
        self.id = id
        self.author = author
        self.text = text
        self.timestamp = timestamp
    }

    let id: UUID

    var author: Contact
    var text: String
    let timestamp: Date
}
