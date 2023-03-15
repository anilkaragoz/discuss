import SwiftUI

struct IMessageTemplateView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        EmptyView()
    }

    static func customNavigationBar(scenario: Binding<Scenario>, onDismiss: @escaping () -> Void) -> some View {
        ZStack {
            VStack(alignment: .center, spacing: 0) {
                VStack {
                    if let image = scenario.wrappedValue.recipient.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())

                    } else if scenario.wrappedValue.recipient.name.first?.isLetter == false {
                        Circle()
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .overlay {
                                Image(systemName: "person.crop.circle.fill").resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 48, height: 48)
                                    .clipShape(Circle())
                                    .foregroundColor(.gray)
                            }
                    } else {
                        Text(scenario.wrappedValue.recipient.name.prefix(1)).font(Font.system(size: 30))
                            .padding(18)
                            .foregroundColor(.white)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.gray, .gray.opacity(0.5)]), startPoint: .bottom, endPoint: .top)
                            ).clipShape(Circle())
                    }
                }
                HStack(spacing: 0) {
                    Text(scenario.wrappedValue.recipient.name).font(.caption2).fontWeight(.light)
                    Image(systemName: "chevron.right").font(Font.system(size: 12, weight: .light)).foregroundColor(.secondary)
                }.padding(.bottom, 12)
                    .padding(.top, 4)
                Divider()
            }
            HStack {
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "chevron.left").font(Font.system(size: 24, weight: .regular)).foregroundColor(.accentColor)
                }
                Spacer()
            }.padding().offset(y: -16)
        }
        .background(.thinMaterial)
    }

    static func bubblesView(scenario: Binding<Scenario>, currentMessages: Binding<[Message]>) -> some View {
        VStack {
            if currentMessages.count >= 1 {
                Text(scenario.wrappedValue.palette == ConversationPalette.iMessageDefault ? "iMessage" : "Text message").font(.caption).foregroundColor(.secondary).fontWeight(.semibold)
                HStack(spacing: 2) {
                    Text("scenario_preview.today").font(.caption).bold().foregroundColor(.secondary)
                    Text(scenario.wrappedValue.timestamp, style: .time).font(.caption).foregroundColor(.secondary)
                }
            }
            ForEach(currentMessages, id: \.id) { message in
                let backgroundColor = message.wrappedValue.author.id == scenario.wrappedValue.me.id ? scenario.wrappedValue.palette.sender : scenario.wrappedValue.palette
                    .recipient

                ChatBubble(direction: message.wrappedValue.author.id == scenario.wrappedValue.me.id ? .right : .left) {
                    Text(message.wrappedValue.text)
                        .padding(.horizontal, 14)
                        .padding(.trailing, 4)
                        .padding(.vertical, 10)
                        .foregroundColor(backgroundColor.isDarkBackground ? .white : .black)
                        .background(backgroundColor)
                        .id(message.wrappedValue.id)
                }
            }
            Spacer()
        }
        .padding(.top, 4)
        .padding(.bottom, 40)
        .padding(.horizontal)
        .animation(.easeOut(duration: 0.2), value: currentMessages.wrappedValue)
    }
}
