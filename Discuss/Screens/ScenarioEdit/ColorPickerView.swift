import SwiftUI

// MARK: - BackgroundPicker

struct ConversationPalette: Codable {
    let sender: Color
    let recipient: Color
}

extension ConversationPalette {
    static let all: [ConversationPalette] = [
        .defaultPalette,
        .pamplemousse,
        .monochrome,
        .greenMint,
        .honeyMoon,
        .iMessageDefault,
        .iMessageText
    ]
}

extension ConversationPalette {
    static let iMessageDefault = ConversationPalette(sender: .green, recipient: Color(uiColor: .systemGroupedBackground))
    static let iMessageText = ConversationPalette(sender: .blue, recipient: Color(uiColor: .systemGroupedBackground))
    static let monochrome = ConversationPalette(sender: Color(0x2F3331), recipient: Color(uiColor: .systemGroupedBackground))
    static let greenMint = ConversationPalette(sender: Color(0x0E8A78), recipient: Color(uiColor: .systemGroupedBackground))
    static let pamplemousse = ConversationPalette(sender: Color(0xF25F64), recipient: Color(0xFFCA9B))
    static let honeyMoon = ConversationPalette(sender: Color(0xffea72), recipient: Color(0x2B2E32))
    static let defaultPalette = ConversationPalette(sender: Color(0x7B88FE), recipient: Color(uiColor: .systemGroupedBackground))
}

extension ConversationPalette: Hashable {}

extension Color {
    init(_ hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

struct PalettePicker: View {
    @Environment(\.presentationMode) var presentation

    enum Constant {
        static let itemSize: CGSize = .init(width: 44.0, height: 44.0)
    }

    @Binding var selectedPalette: ConversationPalette

    var columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 25) {
                        ForEach(ConversationPalette.all, id: \.self) { palette in
                            colorItem(palette: palette, selected: palette == selectedPalette)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("palette_picker.title")
            .navigationBarItems(trailing:
                Button(action: {
                    presentation.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                })
                .foregroundColor(.gray)
            )
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    // MARK: - Views

    private func colorItem(palette: ConversationPalette, selected: Bool) -> some View {
        let length = Constant.itemSize.height

        return AnyView(
            Button {
                selectedPalette = palette
            } label: {
                HStack(spacing: 0) {
                    Rectangle().foregroundColor(palette.recipient)
                    Rectangle().foregroundColor(palette.sender)
                }.frame(width: length, height: length).clipShape(Circle()).rotationEffect(.degrees(-45))
                    .overlay(
                        Circle()
                            .stroke(.black.opacity(0.1), lineWidth: 3.0)
                            .padding(1)
                    )
                    .if(selected) {
                        $0.overlay(
                            Circle()
                                .stroke(.blue, lineWidth: 4.0)
                                .padding(-5)
                        )
                    }
            }
        )
    }
}

struct PalettePicker_Previews: PreviewProvider {
    static var previews: some View {
        PalettePicker(selectedPalette: .constant(ConversationPalette.defaultPalette))
    }
}
