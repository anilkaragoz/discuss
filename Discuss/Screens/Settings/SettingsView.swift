import MessageUI
import StoreKit
import SwiftUI

struct SettingsView: View {
    enum SheetKind: Identifiable {
        case mail
        case termsOfUse
        case privacyPolicy
        case supportFAQ

        var id: Int {
            hashValue
        }
    }

    @State var activeSheet: SheetKind?
    @State var showMailAlert = false

    let termsOfUseUrl = URL(string: "https://www.google.com")!
    let privacyPolicyUrl = URL(string: "https://www.google.com")!
    let supportFAQUrl = URL(string: "https://www.google.com")!

    var body: some View {
        Form {
            Section(header: Text("settings.section.contact")) {
                Button(action: {
                    if MFMailComposeViewController.canSendMail() {
                        activeSheet = .mail
                    } else {
                        showMailAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "envelope")
                        Text("settings.contact.mail")
                            .foregroundColor(.primary)
                    }
                }

                Button(action: {
                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }) {
                    HStack {
                        Image(systemName: "star")
                        Text("settings.contact.rate")
                            .foregroundColor(.primary)
                    }
                }
            }
        }.sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .mail:
                mailSheet
            case .termsOfUse:
                termsOfUseSheet
            case .privacyPolicy:
                privacyPolicySheet
            case .supportFAQ:
                supportFAQSheet
            }
        }.alert(isPresented: $showMailAlert) {
            Alert(title: Text("settings.alert.no-mail-configured"))
        }
    }

    var mailSheet: some View {
        MailView(
            content:
            """


            ------------
            \(DeviceManager().deviceDebug)
            """,
            to: "",
            subject: "[Discuss] Support Message"
        )
    }

    var termsOfUseSheet: some View {
        NavigationView {
            WebView(url: termsOfUseUrl)
                .navigationBarItems(trailing:
                    Button(action: {
                        activeSheet = nil
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                    })
                    .buttonBorderShape(.roundedRectangle)
                    .controlSize(.mini)
                )
        }
    }

    var privacyPolicySheet: some View {
        NavigationView {
            WebView(url: privacyPolicyUrl)
                .navigationBarItems(trailing:
                    Button(action: {
                        activeSheet = nil
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                    })
                    .buttonBorderShape(.roundedRectangle)
                    .controlSize(.mini)
                )
        }
    }

    var supportFAQSheet: some View {
        NavigationView {
            WebView(url: supportFAQUrl)
                .navigationBarItems(trailing:
                    Button(action: {
                        activeSheet = nil
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                    })
                    .buttonBorderShape(.roundedRectangle)
                    .controlSize(.mini)
                )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
