import SwiftUI
import UIKit

struct TextView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String?
    var placeholderLabel = UILabel()

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = .clear

        textView.addDoneButton(title: "misc.done".localized, target: self)
        textView.delegate = context.coordinator
        textView.text = text

        placeholderLabel.text = placeholder
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = .secondaryLabel
        placeholderLabel.isHidden = !textView.text.isEmpty

        return textView
    }

    func updateUIView(_ uiView: UITextView, context _: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView

        init(_ parent: TextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.placeholderLabel.isHidden = !textView.text.isEmpty
            parent.text = textView.text
        }
    }
}

extension UITextView {
    
    @objc func doneTapped() {
        self.resignFirstResponder()
    }
    
    func addDoneButton(title: String, target: Any) {
        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: #selector(doneTapped))
        toolBar.setItems([flexible, barButton], animated: false)
        inputAccessoryView = toolBar
    }
}
