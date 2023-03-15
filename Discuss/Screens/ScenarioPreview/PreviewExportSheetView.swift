import SwiftUI

struct PreviewExportSheetView: View {
    enum ExportOption {
        case photo
        case video
    }

    var onTap: ((ExportOption) -> Void)? = nil

    var body: some View {
        VStack {
            HStack(spacing: 60) {
                Button {
                    onTap?(.photo)
                } label: {
                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 28.0, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(width: 80, height: 80)
                            .background(.blue.opacity(0.1))
                            .cornerRadius(80 * 0.2237, antialiased: true)
                        Text("export_options.button.image")
                            .font(.system(size: 17.0, weight: .bold, design: .rounded))
                            .padding(.init(top: 2, leading: 6, bottom: 2, trailing: 6))
                            .foregroundColor(.blue)
                    }
                }
                ZStack {
                    Button {
                        onTap?(.video)
                    } label: {
                        VStack {
                            Image(systemName: "video.bubble.left")
                                .font(.system(size: 32.0, weight: .bold))
                                .foregroundColor(.gray)
                                .frame(width: 80, height: 80)
                                .background(.gray.opacity(0.1))
                                .cornerRadius(80 * 0.2237, antialiased: true)
                            Text("export_options.button.video")
                                .font(.system(size: 17.0, weight: .bold, design: .rounded))
                                .padding(.init(top: 2, leading: 6, bottom: 2, trailing: 6))
                                .foregroundColor(.gray)
                        }
                    }
                    .disabled(true)
                    Text("export_options.button.coming_soon").font(.caption).foregroundColor(.white).bold().padding(4).background(RoundedRectangle(cornerRadius: 10).foregroundColor(.blue)).offset(y: -72)
                }
            }
        }
    }
}

struct PreviewExportSheetView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewExportSheetView()
    }
}
