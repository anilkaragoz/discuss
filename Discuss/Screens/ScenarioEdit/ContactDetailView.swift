import Contacts
import SwiftUI

struct ContactDetailView: View {
    @State var isCroppedImagePickerPresented = false
    @State var name = ""
    @State var image: UIImage? = nil
    @State var showContactImport = false

    var onCompletion: ((Contact) -> Void)? = nil

    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
            if showContactImport {
                ContactPickerView(showPicker: $showContactImport) { contact in
                    name = contact.givenName

                    if let imageData = contact.imageData {
                        image = UIImage(data: imageData)
                    } else {
                        image = nil
                    }

                    showContactImport = false
                }
            }

            VStack {
                Button {
                    isCroppedImagePickerPresented = true
                } label: {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140, height: 140)
                            .foregroundColor(.gray)
                            .overlay(
                                VStack {
                                    Spacer()
                                    Text("contact_detail.button.image_edit").fontWeight(.light)
                                        .frame(width: 200, height: 30)
                                        .foregroundColor(.white)
                                        .background(.black.opacity(0.8))
                                }
                            ).clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140, height: 140)
                            .foregroundColor(.gray)
                            .overlay(
                                VStack {
                                    Spacer()
                                    Text("contact_detail.button.image_edit").fontWeight(.light)
                                        .frame(width: 200, height: 30)
                                        .foregroundColor(.white)
                                        .background(.black.opacity(0.8))
                                }
                            ).clipShape(Circle())
                    }
                }
                Form {
                    Section {
                        TextField("contact_detail.name.placeholder", text: $name)
                    }
                    Section("contact_detail.section.actions") {
                        Button {
                            showContactImport = true
                        } label: {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                Text("contact_detail.section.actions.import_from_phone")
                            }
                        }
                    }
                }
                Spacer()
                Button {
                    let contact = Contact(image: image, name: name)
                    onCompletion?(contact)
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill").foregroundColor(.white)
                        Text("misc.done")
                    }.padding().bold().foregroundColor(.white).frame(maxWidth: .infinity).background(.blue).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }.buttonStyle(.plain)
            }.padding()
        }.fullScreenCover(isPresented: $isCroppedImagePickerPresented) {
            CroppedImagePicker(croppedImage: $image)
        }
    }
}

struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContactDetailView()
    }
}
