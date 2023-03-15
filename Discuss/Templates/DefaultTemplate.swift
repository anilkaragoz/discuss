import SwiftUI

struct DefaultTemplateView {
    struct BubblesView: View {
        @Binding var currentMessages: [Message]
        @Binding var scenario: Scenario

        var body: some View {
            VStack {
                if currentMessages.count >= 1 {
                    HStack(spacing: 2) {
                        Text("scenario_preview.today").font(.caption).bold().foregroundColor(.secondary)
                    }
                }
                ForEach(currentMessages, id: \.id) { message in
                    let backgroundColor = message.author.id == scenario.me.id ? scenario.palette.sender : scenario.palette
                        .recipient

                    HStack {
                        if message.author.id == scenario.me.id {
                            Spacer()
                        }
                        VStack(alignment: .leading) {
                            VStack {
                                Text(message.text)
                                    .padding()
                                    .foregroundColor(backgroundColor.isDarkBackground ? .white : .black)
                                    .background(backgroundColor)
                                    .id(message.id)
                            }.if(message.author.id == scenario.me.id) {
                                $0.clipShape(RoundedCorner(radius: 20, corners: [.bottomLeft, .topLeft, .topRight]))
                            }.if(message.author.id != scenario.me.id) {
                                $0.clipShape(RoundedCorner(radius: 20, corners: [.bottomRight, .bottomLeft, .topRight]))
                            }
                            Text(scenario.timestamp, style: .time).font(.caption).foregroundColor(.secondary)
                        }
                        if message.author.id != scenario.me.id {
                            Spacer()
                        }
                    }.padding(8)
                }
                Spacer()
            }
            .padding(.top, 4)
            .padding(.bottom, 40)
            .padding(.horizontal)
            .animation(.easeOut(duration: 0.2), value: currentMessages)
        }
    }

    struct CustomNavigationBar: View {
        @Environment(\.dismiss) var dismiss
        @Binding var scenario: Scenario

        var body: some View {
            HStack(alignment: .center) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left").font(Font.system(size: 20, weight: .regular)).foregroundColor(.black)
                }
                if let image = scenario.recipient.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())

                } else if scenario.recipient.name.first?.isLetter == false {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image(systemName: "person.crop.circle.fill").resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        }
                } else {
                    Text(scenario.recipient.name.prefix(1)).font(Font.system(size: 18))
                        .padding(14)
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.gray, .gray.opacity(0.5)]), startPoint: .bottom, endPoint: .top)
                        ).clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white, lineWidth: 1)
                                .background(Circle().foregroundColor(Color.green))
                                .frame(width: 10, height: 10).offset(x: 12, y: 12)
                        )
                }

                VStack(alignment: .leading) {
                    Text(scenario.recipient.name).font(.title3).fontWeight(.semibold)
                    Text("scenario_preview.active_now").foregroundColor(.gray).bold().font(.caption)
                }.padding(.leading)
                Spacer()
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                Image(systemName: "ellipsis").rotationEffect(.degrees(90)).foregroundColor(.gray)
            }
            .padding()
            .background(.white)
            .overlay(Rectangle().frame(width: nil, height: 0.5, alignment: .bottom).foregroundColor(Color.gray.opacity(0.5)), alignment: .bottom)
        }
    }
}
