import SwiftUI

struct ScenarioEditView: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var viewModel: ScenarioEditViewModel
    @StateObject var scenarioDataManager = ScenarioDataManager.shared

    @State var isPreviewPresented = false
    @State var isContactDetailViewPresented = false
    @State var isTimePickerPresented = false
    @State var isSavePresented = false
    @State var isDismissAlertPresented = false
    @State var isDeleteAlertPresented = false
    @State var isEmptyMessageAlertPresented = false
    @State var isPalettePickerPresented = false

    @FocusState var focusedField: UUID?

    init(viewModel: ScenarioEditViewModel, isPreviewPresented: Bool = false, isContactDetailViewPresented: Bool = false, isTimePickerPresented: Bool = false, isSavePresented: Bool = false, focusedField: UUID? = nil) {
        self.viewModel = viewModel
        self.isPreviewPresented = isPreviewPresented
        self.isContactDetailViewPresented = isContactDetailViewPresented
        self.isTimePickerPresented = isTimePickerPresented
        self.isSavePresented = isSavePresented
        self.focusedField = focusedField

        let toolbarAppearance = UIToolbarAppearance()
        toolbarAppearance.configureWithDefaultBackground()

        UIToolbar.appearance().scrollEdgeAppearance = toolbarAppearance
    }

    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        contactSection.background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color(uiColor: .secondarySystemGroupedBackground)).shadow(color: .black.opacity(0.1), radius: 8)).padding()

                        settingsSection.background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color(uiColor: .secondarySystemGroupedBackground)).shadow(color: .black.opacity(0.1), radius: 8)).padding()

                        ForEach($viewModel.scenario.messages, id: \.id) { message in
                            textSection(message: message).background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color(uiColor: .secondarySystemGroupedBackground)).shadow(color: .black.opacity(0.1), radius: 8)).padding()
                        }

                        Section {
                            Button {
                                viewModel.addMessage()
                                focusedField = viewModel.scenario.messages.last?.id
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                                    withAnimation {
                                        proxy.scrollTo("bottom")
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill").foregroundColor(.white)
                                    Text("scenario_edit.new_message")
                                }.padding().bold().foregroundColor(.white).frame(maxWidth: .infinity).background(.blue).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous)).padding()
                            }
                        }.id("bottom")
                        Spacer()
                    }
                }
                .onChange(of: focusedField, perform: { newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        withAnimation {
                            proxy.scrollTo(newValue)
                        }
                    }
                })
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("scenario_edit.toolbar.title").font(.headline).padding(.leading, 20).lineLimit(1)
                    }
                }
                .toolbarTitleMenu {
                    Button {
                        isSavePresented = true
                    } label: {
                        HStack {
                            Text("scenario_edit.toolbar.rename")
                            Image(systemName: "pencil")
                        }
                    }
                    Button {
                    } label: {
                        HStack {
                            Text("scenario_edit.toolbar.duplicate")
                            Image(systemName: "plus.rectangle.on.rectangle")
                        }
                    }.disabled(true)
                }
                .navigationBarItems(leading: cancelButton, trailing: saveButton)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            isDeleteAlertPresented = true
                        } label: {
                            Image(systemName: "trash").foregroundColor(.red)
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            if viewModel.scenario.messages.isEmpty || viewModel.scenario.messages.contains(where: { $0.text.isEmpty }) {
                                isEmptyMessageAlertPresented = true
                            } else {
                                isPreviewPresented = true
                            }
                        } label: {
                            Image(systemName: "iphone.badge.play")
                        }
                    }
                }
            }.background(Color(uiColor: .secondarySystemBackground))
                .alert(isPresented: $isEmptyMessageAlertPresented) {
                    Alert(
                        title: Text("scenario_edit.alert.empty_messages.title"),
                        message: Text("scenario_edit.alert.empty_messages.description"),
                        dismissButton: .default(Text("misc.ok"), action: {
                            isEmptyMessageAlertPresented = false
                        })
                    )
                }
        }
        .sheet(isPresented: $isPalettePickerPresented) {
            PalettePicker(selectedPalette: $viewModel.scenario.palette).presentationDetents([.fraction(0.4)])
        }
        .sheet(isPresented: $isSavePresented) {
            saveView.presentationDetents([.fraction(0.4)])
        }
        .fullScreenCover(isPresented: $isPreviewPresented) {
            ScenarioPreview(
                scenario: viewModel.scenario
            )
        }
        .sheet(isPresented: $isContactDetailViewPresented) {
            NavigationView {
                ContactDetailView(
                    name: viewModel.scenario.recipient.name,
                    image: viewModel.scenario.recipient.image,
                    onCompletion: { contact in
                        viewModel.didEditRecipient(contact: contact)
                        isContactDetailViewPresented = false
                    }
                )
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("contact_detail.title")
                .navigationBarItems(trailing:
                    Button(action: {
                        isContactDetailViewPresented = false
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                    })
                    .buttonBorderShape(.roundedRectangle)
                    .controlSize(.mini)
                )
            }.presentationDetents([.fraction(0.75)])
        }.alert(isPresented: $isDeleteAlertPresented) {
            Alert(
                title: Text("scenario_edit.alert.delete.title"),
                message: Text("scenario_edit.alert.delete.description"),
                primaryButton: .destructive(Text("misc.confirm"), action: {
                    let isEdition = scenarioDataManager.scenario(withId: viewModel.scenario.id) != nil

                    if isEdition {
                        scenarioDataManager.remove(viewModel.scenario)
                    }

                    dismiss()
                }),
                secondaryButton: .default(Text("misc.cancel"), action: {
                    isDeleteAlertPresented = false
                })
            )
        }
    }

    var contactSection: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.rectangle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundColor(.secondary)
                Text("scenario_edit.recipient").fontWeight(.medium)
                Spacer()
                if !viewModel.scenario.recipient.name.isEmpty {
                    Button {
                        isContactDetailViewPresented = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil").foregroundColor(.accentColor)
                            Text("misc.edit").foregroundColor(.accentColor).fontWeight(.medium)
                        }
                    }.buttonStyle(.plain)
                }
            }
            if viewModel.scenario.recipient.name.isEmpty {
                Button {
                    isContactDetailViewPresented = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill").foregroundColor(.white)
                        Text("scenario_edit.add_contact")
                    }.padding().bold().foregroundColor(.white).frame(maxWidth: .infinity).background(.blue).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }.buttonStyle(.plain)
            } else {
                HStack {
                    Spacer()
                    VStack(alignment: .center) {
                        if let image = viewModel.scenario.recipient.image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                                .clipShape(Circle())
                        }
                        Text(viewModel.scenario.recipient.name).fontWeight(.medium)
                    }
                    Spacer()
                }
            }
        }.padding()
    }

    var settingsSection: some View {
        VStack {
            HStack {
                DatePicker(selection: $viewModel.scenario.timestamp, displayedComponents: .hourAndMinute) {
                    Text("scenario_edit.settings.starting_hour")
                }
                .datePickerStyle(GraphicalDatePickerStyle())
            }
            HStack {
                Text("scenario.edit.current_palette")
                Spacer()
                Button {
                    isPalettePickerPresented = true
                } label: {
                    HStack(spacing: 0) {
                        Rectangle().foregroundColor(viewModel.scenario.palette.recipient)
                        Rectangle().foregroundColor(viewModel.scenario.palette.sender)
                    }.frame(width: 36, height: 36).clipShape(Circle()).rotationEffect(.degrees(-45))
                        .overlay(
                            Circle()
                                .stroke(.black.opacity(0.1), lineWidth: 3.0)
                                .padding(1)
                        )
                }
            }
        }
        .padding()
    }

    var saveButton: some View {
        Button {
            guard viewModel.scenario.messages.contains(where: { $0.text.isEmpty }) == false else {
                isEmptyMessageAlertPresented = true
                return
            }

            let isEdition = scenarioDataManager.scenario(withId: viewModel.scenario.id) != nil

            if isEdition {
                scenarioDataManager.edit(viewModel.scenario)
            } else {
                scenarioDataManager.add(viewModel.scenario)
            }

            dismiss()
        } label: {
            Text("misc.save")
        }
    }

    var cancelButton: some View {
        Button {
            if viewModel.scenario.recipient.name.isEmpty && viewModel.scenario.messages.isEmpty {
                dismiss()
                return
            }

            let cachedScenario = scenarioDataManager.scenario(withId: viewModel.scenario.id)

            if let cachedScenario = cachedScenario, cachedScenario == viewModel.scenario {
                dismiss()
            } else {
                isDismissAlertPresented = true
            }
        } label: {
            Text("misc.cancel")
        }.alert(isPresented: $isDismissAlertPresented) {
            Alert(
                title: Text("scenario_edit.alert.cancel.title"),
                message: Text("scenario_edit.alert.cancel.description"),
                primaryButton: .destructive(Text("misc.confirm"), action: {
                    dismiss()
                }),
                secondaryButton: .default(Text("misc.cancel"), action: {
                    isDismissAlertPresented = false
                })
            )
        }
    }

    var saveView: some View {
        NavigationView {
            ScenarioSaveView(
                isPresented: $isSavePresented,
                scenario: $viewModel.scenario
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("scenario_edit.rename_conversation")
            .navigationBarItems(trailing:
                Button(action: {
                    isSavePresented = false
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                })
                .buttonBorderShape(.roundedRectangle)
                .controlSize(.mini)
            )
        }
    }

    func textSection(message: Binding<Message>) -> some View {
        VStack {
            HStack {
                VStack {
                    Image(systemName: "message.fill").foregroundColor(.white).padding(3)
                }.background(Color.green).clipShape(RoundedRectangle(cornerRadius: 5))
                Text("scenario_edit.text_section.send_message").fontWeight(.medium)
                Spacer()
                Button {
                    viewModel.scenario.messages.removeAll { currMessage in
                        currMessage.id == message.wrappedValue.id
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                }.buttonStyle(.plain)
            }

            TextView(text: message.text, placeholder: "scenario_edit.enter_message_prompt".localized)
                .frame(maxHeight: .infinity)
                .padding(8)
                .focused($focusedField, equals: message.wrappedValue.id)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.vertical)

            HStack {
                Text("scenario_edit.from")
                Menu {
                    Button(viewModel.scenario.me.name) {
                        viewModel.changeAuthor(message: message.wrappedValue, author: viewModel.scenario.me)
                    }
                    Button(viewModel.scenario.recipient.name) {
                        viewModel.changeAuthor(message: message.wrappedValue, author: viewModel.scenario.recipient)
                    }
                } label: {
                    VStack {
                        Text(message.wrappedValue.author.name).foregroundColor(.accentColor).bold().padding(6)
                    }.background(Color.blue.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
            }
        }.padding().frame(height: 220)
    }
}

struct ScenarioEditView_Previews: PreviewProvider {
    static var previews: some View {
        ScenarioEditView(viewModel: ScenarioEditViewModel(
            recipient: Contact(image: nil, name: ""),
            me: Contact(image: nil, name: "Me"),
            messages: []
        ))
    }
}
