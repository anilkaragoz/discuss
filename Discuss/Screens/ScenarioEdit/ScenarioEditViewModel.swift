import UIKit

class ScenarioEditViewModel: ObservableObject, Identifiable {
    internal init(recipient: Contact, me: Contact, messages: [Message]) {
        scenario = Scenario(name: "", messages: messages, me: me, recipient: recipient, palette: ConversationPalette.defaultPalette, timestamp: Date())
    }

    internal init(scenario: Scenario) {
        self.scenario = scenario
    }

    @Published var showContactPopover = false
    @Published var scenario: Scenario

    func addMessage() {
        let newMessage: Message

        if scenario.messages.isEmpty {
            newMessage = Message(author: scenario.me, text: "", timestamp: Date())
        } else if scenario.messages.last?.author.id == scenario.me.id && !scenario.recipient.name.isEmpty {
            newMessage = Message(author: scenario.recipient, text: "", timestamp: Date())
        } else {
            newMessage = Message(author: scenario.me, text: "", timestamp: Date())
        }

        scenario.messages.append(newMessage)
    }

    func changeAuthor(message: Message, author: Contact) {
        let newMessage = Message(id: message.id, author: author, text: message.text, timestamp: Date())

        scenario.messages = scenario.messages.map {
            if $0.id == message.id {
                return newMessage
            }

            return $0
        }
    }

    func didEditRecipient(contact: Contact) {
        let newContact = Contact(id: contact.id, image: contact.image, name: contact.name)

        scenario.messages = scenario.messages.map {
            if $0.author.id == scenario.recipient.id {
                let newMessage = Message(id: $0.id, author: newContact, text: $0.text, timestamp: $0.timestamp)

                return newMessage
            }

            return $0
        }

        scenario.recipient = newContact
    }
}
