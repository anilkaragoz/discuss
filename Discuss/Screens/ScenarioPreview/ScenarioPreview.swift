import SwiftUI

struct ScenarioPreview: View {
    @State var scenario: Scenario
    @State var currentMessages: [Message] = []
    @State var capture: UIImage?
    @State var isPlaying = false

    @State var animationTask: Task<Void, Error>? = nil
    @State var isExportSheetPresented = false
    @State var isExportResultPresented = false
    @State var imageExportPresented = false

    @State var shareImage = false

    private let bottomId = "bottomId"
    @Environment(\.dismiss) var dismiss

    // MARK: Views

    var body: some View {
        ZStack {
            Color(uiColor: .black).ignoresSafeArea(.all)
            VStack {
                content
                toolbar
            }
        }.sheet(isPresented: $isExportSheetPresented) {
            exportSheetView.presentationDetents([.fraction(0.3)])
        }.sheet(isPresented: $imageExportPresented) { [capture] in
            VStack {
                Image(uiImage: capture ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(height: 500)
            }
        }.sheet(isPresented: $isExportResultPresented, content: {
            exportResultView
        })
        .shareSheet(show: $shareImage, items: [capture])
        .navigationBarHidden(true)
    }

    var content: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                switch scenario.template {
                case .iMessage:
                    IMessageTemplateView.bubblesView(scenario: $scenario, currentMessages: $currentMessages).frame(maxWidth: .infinity)
                case .default:
                    DefaultTemplateView.BubblesView(currentMessages: $currentMessages, scenario: $scenario).frame(maxWidth: .infinity)
                }
                Spacer().id(bottomId)
            }
            .onAppear {
                currentMessages = scenario.messages
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                    withAnimation {
                        proxy.scrollTo(bottomId)
                    }
                }
            }
            .onChange(of: currentMessages) { _ in
                withAnimation {
                    proxy.scrollTo(bottomId)
                }
            }
        }
        .safeAreaInset(edge: .top) {
            switch scenario.template {
            case .iMessage:
                IMessageTemplateView.customNavigationBar(scenario: $scenario) {
                    dismiss()
                }
            case .default:
                DefaultTemplateView.CustomNavigationBar(scenario: $scenario)
            }
        }
        .background(
            VStack {
                switch scenario.template {
                case .iMessage:
                    Color.white.clipShape(RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight])).ignoresSafeArea(.all)
                case .default:
                    Color(uiColor: .secondarySystemGroupedBackground).clipShape(RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight])).ignoresSafeArea(.all)
                }
            }
        )
    }

    var toolbar: some View {
        HStack(spacing: 16) {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left").font(Font.system(size: 24, weight: .regular)).foregroundColor(.accentColor)
                    Text("misc.back")
                        .bold()
                        .foregroundColor(.blue)
                }
            }
            Spacer()
            Button {
                isExportSheetPresented = true
            } label: {
                Text("misc.export")
                    .bold()
                    .frame(minWidth: 60)
                    .padding(12)
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }.overlay {
            HStack {
                Spacer()
                Button {
                    if isPlaying {
                        stopAnimation()
                    } else {
                        startAnimation()
                    }

                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .foregroundColor(.accentColor)
                        .fontWeight(.heavy)
                }
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    var exportSheetView: some View {
        NavigationView {
            PreviewExportSheetView(onTap: { action in
                switch action {
                case .photo:
                    isExportSheetPresented = false

                    // Wait for sheet to finish dismissing
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                        capture = getCroppedScreenshot()
                        isExportResultPresented = true
                    }
                case .video:
                    isExportSheetPresented = false
                }
            })
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("export_options.title")
            .navigationBarItems(trailing:
                Button(action: {
                    isExportSheetPresented = false
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                })
                .buttonBorderShape(.roundedRectangle)
                .controlSize(.mini)
            )
        }
    }

    var exportResultView: some View {
        NavigationView {
            ScenarioExportView(isPresented: $isExportResultPresented, originalImage: capture ?? UIImage())
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("export.image.title")
                .navigationBarItems(trailing:
                    Button(action: {
                        isExportResultPresented = false
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                    })
                    .buttonBorderShape(.roundedRectangle)
                    .controlSize(.mini)
                )
        }
    }

    // MARK: Methods

    func startAnimation() {
        animationTask?.cancel()

        currentMessages = []
        animationTask = Task {
            for message in scenario.messages {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                try Task.checkCancellation()
                currentMessages.append(message)
            }

            isPlaying = false
        }
    }

    func stopAnimation() {
        animationTask?.cancel()

        currentMessages = scenario.messages
    }

    @MainActor func getCroppedScreenshot() -> UIImage {
        let view = content.frame(
            width: UIScreen.main.bounds.size.width,
            height: UIScreen.main.bounds.size.height
        )

        let sourceImage = view.takeScreenshot(frame: UIScreen.main.bounds, afterScreenUpdates: true)

        let toolbarOffset = 120.0
        let sourceSize = sourceImage.size

        let cropRect = CGRect(
            x: 0,
            y: 0,
            width: sourceSize.width,
            height: sourceSize.height - toolbarOffset
        )

        let croppedImage = sourceImage.cropped(to: cropRect)!
        return croppedImage
    }
}

extension View {
    func shareSheet(show: Binding<Bool>, items: [Any?]) -> some View {
        return sheet(isPresented: show) {
            let items = items.compactMap { item -> Any? in
                item
            }

            if !items.isEmpty {
                ShareSheet(items: items)
            }
        }
    }

    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

public extension View {
    func takeScreenshot(frame: CGRect, afterScreenUpdates: Bool) -> UIImage {
        let hosting = UIHostingController(rootView: self)
        hosting.overrideUserInterfaceStyle = UIApplication.shared.kWindow?.overrideUserInterfaceStyle ?? UIUserInterfaceStyle.unspecified
        hosting.view.frame = frame
        return hosting.view.takeScreenshot(afterScreenUpdates: afterScreenUpdates)
    }
}

public extension UIView {
    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot!
    }

    func takeScreenshot(afterScreenUpdates: Bool) -> UIImage {
        if !responds(to: #selector(drawHierarchy(in:afterScreenUpdates:))) {
            return self.takeScreenshot()
        }
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        UIApplication.shared.kWindow?.drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot!
    }
}

extension UIImage {
    func cropped(to rect: CGRect) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = scale

        return UIGraphicsImageRenderer(size: rect.size, format: format).image { _ in
            let origin = CGPoint(x: -rect.minX, y: -rect.minY)
            draw(in: CGRect(origin: origin, size: size))
        }
    }
}

extension UIApplication {
    var currentScene: UIWindowScene? {
        connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
    }

    var kWindow: UIWindow? {
        // Get connected scenes
        return currentScene?
            // Get its associated windows
            .windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
}

struct ScenarioPreview_Preview: PreviewProvider {
    static var previews: some View {
        let me = Contact(image: nil, name: "Me")
        let recipient = Contact(image: nil, name: "Dad")

        let messages: [Message] = [
            .init(author: me, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", timestamp: Date()),
            .init(author: recipient, text: "Fusce aliquet viverra nibh, at laoreet orci vehicula tincidunt.", timestamp: Date()),
            .init(author: recipient, text: "Sed rutrum semper scelerisque.", timestamp: Date()),
            .init(author: recipient, text: "Sure!", timestamp: Date()),
            .init(author: recipient, text: "Fusce aliquet viverra nibh, at laoreet orci vehicula tincidunt.", timestamp: Date()),
            .init(author: recipient, text: "Sed rutrum semper scelerisque.", timestamp: Date()),
            .init(author: recipient, text: "Fusce aliquet viverra nibh, at laoreet orci vehicula tincidunt.", timestamp: Date()),
            .init(author: recipient, text: "Sed rutrum semper scelerisque.", timestamp: Date()),
            .init(author: recipient, text: "Fusce aliquet viverra nibh, at laoreet orci vehicula tincidunt.", timestamp: Date()),
            .init(author: recipient, text: "Sed rutrum semper scelerisque.", timestamp: Date()),
            .init(author: recipient, text: "Fusce aliquet viverra nibh, at laoreet orci vehicula tincidunt.", timestamp: Date()),
            .init(author: recipient, text: "Sed rutrum semper scelerisque.", timestamp: Date())
        ]

        ScenarioPreview(scenario:
            Scenario(name: "Test",
                     messages: messages,
                     me: me,
                     recipient: recipient,
                     palette:
                     ConversationPalette.defaultPalette,
                     timestamp: Date(),
                     template: .default)
        )
    }
}
