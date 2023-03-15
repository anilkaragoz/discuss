import SwiftUI

struct ScenarioSaveView: View {
    @Binding var isPresented: Bool
    @Binding var scenario: Scenario
    @StateObject var scenarioDataManager = ScenarioDataManager.shared

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if let image = scenario.recipient.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                        .clipShape(Circle())
                }
                Text(scenario.recipient.name).bold()
                Spacer()
                Text("\(scenario.messages.count) \(scenario.messages.count > 1 ? "messages" : "message")").foregroundColor(.secondary).bold()
            }.padding(.horizontal, 20)
            Form {
                Section {
                    TextField("scenario_edit.scenario.name.placeholder", text: $scenario.name)
                }
            }
            Button {
                saveScenario()
                isPresented = false
            } label: {
                Text("misc.done")
                    .padding()
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }.padding()
        }.background(Color(uiColor: .secondarySystemBackground))
    }

    func saveScenario() {
    }
}

struct ScenarioSaveView_Previews: PreviewProvider {
    static var previews: some View {
        ScenarioSaveView(isPresented: .constant(true), scenario: .constant(Scenario(name: "test", messages: [], me: Contact(image: nil, name: "Bob"), recipient: Contact(image: nil, name: "Test"), palette: ConversationPalette.defaultPalette, timestamp: Date())))
    }
}
