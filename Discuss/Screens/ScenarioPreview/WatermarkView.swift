import SwiftUI

struct WaterMarkView: View {
    var body: some View {
        VStack {
            Text("watermark.text")
                .bold()
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .foregroundColor(.white)
        }.background(Color.black.opacity(0.3)).clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct WaterMarkView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        WaterMarkView().previewLayout(.sizeThatFits)
    }
}
