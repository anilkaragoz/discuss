import ContactsUI
import SwiftUI

public struct ContactPickerView: UIViewControllerRepresentable {
    @Binding var showPicker: Bool
    @State private var viewModel = ContactPickerViewModel()
    public var onSelect: ((_: CNContact) -> Void)?
    public var onCancel: (() -> Void)?

    public init(showPicker: Binding<Bool>, onSelectContact: ((_: CNContact) -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        _showPicker = showPicker
        onSelect = onSelectContact
        self.onCancel = onCancel
    }

    public func makeUIViewController(context _: UIViewControllerRepresentableContext<ContactPickerView>) -> ContactPickerView.UIViewControllerType {
        let dummy = UIViewController()
        viewModel.dummy = dummy
        return dummy
    }

    public func updateUIViewController(_: UIViewController, context: UIViewControllerRepresentableContext<ContactPickerView>) {
        guard viewModel.dummy != nil else {
            return
        }

        let ableToPresent = viewModel.dummy.presentedViewController == nil || viewModel.dummy.presentedViewController?.isBeingDismissed == true

        if showPicker, viewModel.vc == nil, ableToPresent {
            let pickerVC = CNContactPickerViewController()
            pickerVC.delegate = context.coordinator
            viewModel.vc = pickerVC
            viewModel.dummy.present(pickerVC, animated: true)
        }
    }

    public func makeCoordinator() -> ContactPickerCoordinator {
        SingleSelectionCoordinator(self)
    }

    public final class SingleSelectionCoordinator: NSObject, ContactPickerCoordinator {
        var parent: ContactPickerView

        init(_ parent: ContactPickerView) {
            self.parent = parent
        }

        public func contactPickerDidCancel(_: CNContactPickerViewController) {
            parent.showPicker = false
            parent.onCancel?()
        }

        public func contactPicker(_: CNContactPickerViewController, didSelect contact: CNContact) {
            parent.showPicker = false
            parent.onSelect?(contact)
        }
    }
}

class ContactPickerViewModel {
    var dummy: UIViewController!
    var vc: CNContactPickerViewController?
}

public protocol ContactPickerCoordinator: CNContactPickerDelegate {}
