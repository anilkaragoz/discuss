import SwiftUI

struct ScenarioListCellView: View {
    var scenario: Scenario
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 20) {
                if let image = scenario.recipient.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 58, height: 58)
                        .clipShape(Circle())
                } else {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray.lighter(by: 0.2), .gray.darker(by: 0.2)]),
                        startPoint: .top, endPoint: .bottom
                    ).frame(width: 58, height: 58)
                        .mask(
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 58, height: 58)
                                .clipShape(Circle())
                        )
                }
                VStack(alignment: .leading) {
                    Text(scenario.name).bold()
                    Text("\(scenario.messages.count) messages").foregroundColor(.secondary).fontWeight(.light)
                }
                Spacer()
                Text(scenario.timestamp.formatted(date: .omitted, time: .shortened)).foregroundColor(.gray).fontWeight(.light)
            }.padding()
        }
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).foregroundColor(Color(uiColor: .systemGroupedBackground)))
        .shadow(color: .gray.opacity(0.1), radius: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 0.1)
        )
    }
}

struct ScenarioListView: View {
    @StateObject var scenarioDataManager = ScenarioDataManager.shared
    @State var editViewModel: ScenarioEditViewModel?
    @State var isSettingsPresented = false

    var emptyState: some View {
        VStack(spacing: 0) {
            Image(systemName: "bubble.left.and.bubble.right").resizable().aspectRatio(contentMode: .fit).frame(width: 80, height: 80).foregroundColor(.secondary.lighter(by: 0.5)).fontWeight(.thin).padding()
            Text("scenario_list.empty_state.title").font(.largeTitle).fontWeight(.light).bold().foregroundColor(.secondary)
            Text("scenario_list.empty_state.subtitle").fontWeight(.thin).foregroundColor(.secondary)
            Button {
                addTapped()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill").foregroundColor(.blue)
                    Text("scenario_list.empty_state.button.title").foregroundColor(.blue)
                }.padding().bold().foregroundColor(.white).background(.blue.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.blue, lineWidth: 0.4)
                    )
                    .padding()
            }.padding()
            Spacer()
        }.padding(.top, 80)
    }

    var body: some View {
        NavigationView {
            VStack {
                if scenarioDataManager.scenarios.isEmpty {
                    emptyState.padding(.horizontal)
                } else {
                    List {
                        ForEach(scenarioDataManager.scenarios) { scenario in
                            ScenarioListCellView(scenario: scenario) {
                                guard let scenario = scenarioDataManager.scenario(withId: scenario.id) else {
                                    print("Couldn't retrieve conversation with ID: \(scenario.id)")
                                    return
                                }

                                let viewModel = ScenarioEditViewModel(scenario: scenario)
                                self.editViewModel = viewModel
                            }.listRowSeparator(.hidden)
                        }.onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("scenario_list.title")
            .navigationBarItems(trailing: addButton.frame(height: 96, alignment: .trailing))
            .navigationBarItems(leading: settingsButton.frame(height: 96, alignment: .trailing))
        }
        .fullScreenCover(item: $editViewModel) { viewModel in
            ScenarioEditView(viewModel: viewModel)
        }
        .sheet(isPresented: $isSettingsPresented) {
            NavigationView {
                SettingsView()
                    .navigationBarTitle("settings.title")
                    .navigationBarItems(trailing:
                        Button(action: {
                            isSettingsPresented = false
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                        })
                        .buttonBorderShape(.roundedRectangle)
                        .controlSize(.mini)
                    )
            }
        }
    }

    // MARK: - Subviews

    private var addButton: some View {
        Button {
            addTapped()
        } label: {
            Image(systemName: "plus")
        }.foregroundColor(.blue)
            .controlSize(.regular)
    }

    private var settingsButton: some View {
        return AnyView(Button(action: {
            isSettingsPresented = true
        }, label: {
            Image(systemName: "gearshape")
        })
        .foregroundColor(.blue)
        .controlSize(.regular)
        )
    }

    func delete(at offsets: IndexSet) {
        if let index = offsets.first {
            scenarioDataManager.remove(at: index)
        }
    }

    func addTapped() {
        let scenario = Scenario(name: String(format: "scenario.new_conversation".localized, scenarioDataManager.scenarios.count + 1),
                                messages: [],
                                me: Contact(image: nil, name: "scenario.me".localized),
                                recipient: Contact(image: nil, name: ""),
                                palette: ConversationPalette.defaultPalette,
                                timestamp: Date())

        let editViewModel = ScenarioEditViewModel(scenario: scenario)

        self.editViewModel = editViewModel
    }
}

struct ScenarioList_Previews: PreviewProvider {
    static var previews: some View {
        ScenarioListView()
    }
}

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        #if canImport(UIKit)
            typealias NativeColor = UIColor
        #elseif canImport(AppKit)
            typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            return (0, 0, 0, 0)
        }
        return (r, g, b, o)
    }

    func lighter(by percentage: CGFloat = 0.3) -> Color {
        return adjust(by: abs(percentage))
    }

    func darker(by percentage: CGFloat = 0.3) -> Color {
        return adjust(by: -1 * abs(percentage))
    }

    func adjust(by percentage: CGFloat = 0.3) -> Color {
        return Color(red: min(Double(components.red + percentage), 1.0),
                     green: min(Double(components.green + percentage), 1.0),
                     blue: min(Double(components.blue + percentage), 1.0),
                     opacity: Double(components.opacity))
    }
}
