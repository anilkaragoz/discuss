import MessageUI
import SwiftUI

struct MailView: UIViewControllerRepresentable {
    var content: String
    var to: String
    var subject: String

    typealias UIViewControllerType = MFMailComposeViewController

    func updateUIViewController(_: MFMailComposeViewController, context _: Context) {}

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        if MFMailComposeViewController.canSendMail() {
            let view = MFMailComposeViewController()
            view.mailComposeDelegate = context.coordinator
            view.setToRecipients([to])
            view.setSubject(subject)
            view.setMessageBody(content, isHTML: false)
            return view
        } else {
            return MFMailComposeViewController()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(_ parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith _: MFMailComposeResult, error _: Error?) {
            controller.dismiss(animated: true)
        }
    }
}
