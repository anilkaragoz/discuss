import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context _: Context) -> some UIViewController {
        let view = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        return view
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {
    }
}
