import SwiftUI

struct ScenarioExportView: View {
    @Binding var isPresented: Bool
    @State var image: UIImage? = nil

    var originalImage: UIImage

    @State var showShareImage = false
    @State var showSuccess = false

    var body: some View {
        VStack {
            Image(uiImage: image ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.gray, lineWidth: 0.1)
                )
                .frame(maxHeight: 500)
                .padding(.horizontal, 60)
                .padding(.top)
                .shadow(color: .black.opacity(0.2), radius: 10)
            VStack {
                Button {
                    UserProperties.incrementShareCount()
                    showShareImage = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up").bold()
                        Text("misc.share").fontWeight(.bold)
                    }.frame(maxWidth: .infinity)
                }.padding().background(Color.blue.opacity(0.2)).cornerRadius(10).padding(.horizontal)
                Button {
                    UserProperties.incrementSaveCount()
                    guard let image = image else {
                        return
                    }

                    let imageSaver = ImageSaver()

                    imageSaver.successHandler = {
                        withAnimation {
                            showSuccess.toggle()
                        }
                    }

                    imageSaver.writeToPhotoAlbum(image: image)
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down").bold()
                        Text("export.image.save_camera_roll").fontWeight(.bold)
                    }.frame(maxWidth: .infinity)
                }.padding().background(Color.blue.opacity(0.2)).cornerRadius(10).padding(.horizontal)
            }.padding()
            Spacer()
        }.padding(.horizontal)
            .shareSheet(show: $showShareImage, items: [image])
            .hud(show: $showSuccess)
            .onAppear {
                image = originalImage
            }
            .onDisappear {
                RatingController.showRatingIfNeeded()
            }
    }
}

struct ScenarioExportView_Previews: PreviewProvider {
    static var previews: some View {
        ScenarioExportView(isPresented: .constant(true), originalImage: UIImage())
    }
}
